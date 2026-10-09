module Api
  module V1
    class StudentsController < BaseController
      before_action :set_student, only: [:show, :update, :destroy]

      def index
        scope = Student.includes(:classroom).order(:name)
        scope = scope.where(classroom_id: params[:classroomId]) if params[:classroomId].present?
        data = scope.map { |s| student_payload(s) }
        json_response(data: data)
      end

      def show
        json_response(data: student_payload(@student))
      end

      def create
        require_admin!
        return if performed?

        Student.transaction do
          user = User.create!(
            name: params[:name],
            email: params[:email],
            password: params[:password].presence || 'password123',
            role: 'ROLE_STUDENT',
            active: true
          )

          student = Student.create!(
            user: user,
            classroom_id: params[:classroomId],
            nis: params[:nis],
            nisn: params[:nisn],
            name: params[:name],
            email: params[:email],
            phone: params[:phone],
            gender: params[:gender].presence || 'M',
            birth_date: params[:birthDate],
            address: params[:address],
            photo: params[:photo],
            active: params.fetch(:active, true)
          )

          json_response(data: student_payload(student), message: "Student created successfully", status: :created)
        end
      end

      def update
        require_admin!
        return if performed?

        attrs = {
          name: params[:name],
          email: params[:email],
          phone: params[:phone],
          nis: params[:nis],
          nisn: params[:nisn],
          gender: params[:gender],
          birth_date: params[:birthDate],
          address: params[:address],
          photo: params[:photo],
          classroom_id: params[:classroomId],
          active: params[:active]
        }.compact

        @student.update!(attrs)
        @student.user.update!(name: @student.name, email: @student.email) if @student.user
        json_response(data: student_payload(@student), message: "Student updated successfully")
      end

      def destroy
        require_admin!
        return if performed?

        user = @student.user
        @student.destroy!
        user&.destroy!
        json_response(data: nil, message: "Student deleted successfully")
      end

      def exam_cards
        students = Student.includes(:classroom).order(:name)
        cards = students.map do |s|
          {
            studentId: s.id,
            name: s.name,
            nis: s.nis,
            nisn: s.nisn,
            gender: s.gender,
            birthDate: s.birth_date&.to_s,
            classroomName: s.classroom&.name || "-",
            academicYear: s.classroom&.academic_year || "2025/2026",
            barcodeData: "EXAM-#{s.nis}-#{s.id}"
          }
        end
        json_response(data: cards)
      end

      def import_excel
        require_admin!
        return if performed?

        file = params[:file]
        return render_error("Please upload an Excel file") unless file.present?

        temp_path = file.path
        rows = ExcelService.parse_students(temp_path)
        imported_count = 0

        Student.transaction do
          rows.each do |row|
            email = row['email'].presence || "#{row['nis']}@elearning.test"
            user = User.find_or_create_by!(email: email) do |u|
              u.name = row['name']
              u.password = 'password123'
              u.role = 'ROLE_STUDENT'
              u.active = true
            end

            classroom = Classroom.find_by(name: row['classroom']) || Classroom.find_by(id: row['classroom_id'])

            Student.find_or_create_by!(nis: row['nis'].to_s) do |s|
              s.user = user
              s.name = row['name']
              s.email = email
              s.classroom = classroom
              s.nisn = row['nisn']
              s.gender = (row['gender'].to_s.upcase.start_with?('F') ? 'F' : 'M')
              s.phone = row['phone']
              s.active = true
            end
            imported_count += 1
          end
        end

        json_response(data: { count: imported_count }, message: "Imported #{imported_count} students successfully")
      end

      private

      def set_student
        @student = Student.find(params[:id])
      end

      def student_payload(s)
        {
          id: s.id,
          userId: s.user_id,
          name: s.name,
          email: s.email,
          phone: s.phone,
          nis: s.nis,
          nisn: s.nisn,
          birthDate: s.birth_date&.to_s,
          gender: s.gender,
          address: s.address,
          photo: s.photo,
          classroomId: s.classroom_id,
          classroomName: s.classroom&.name,
          active: s.active,
          createdAt: s.created_at&.iso8601
        }
      end
    end
  end
end
