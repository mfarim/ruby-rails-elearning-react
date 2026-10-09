module Api
  module V1
    class LearningMaterialsController < BaseController
      before_action :set_material, only: [:show, :update, :destroy, :record_view, :viewers]

      def index
        scope = LearningMaterial.includes(:teacher, :subject, :classroom).order(created_at: :desc)
        if current_user.teacher?
          scope = scope.where(teacher_id: current_user.teacher&.id)
        elsif current_user.student?
          student = current_user.student
          scope = scope.where(published: true)
          scope = scope.where("classroom_id IS NULL OR classroom_id = ?", student.classroom_id) if student
        end

        student_id = current_user.student&.id
        viewed_material_ids = student_id ? MaterialView.where(student_id: student_id).pluck(:learning_material_id).to_set : Set.new

        data = scope.map { |m| material_payload(m, viewed_material_ids.include?(m.id)) }
        json_response(data: data)
      end

      def show
        has_viewed = current_user.student ? MaterialView.exists?(learning_material_id: @material.id, student_id: current_user.student.id) : false
        json_response(data: material_payload(@material, has_viewed))
      end

      def create
        require_teacher!
        return if performed?

        teacher = current_user.teacher || Teacher.first
        material = LearningMaterial.create!(
          teacher: teacher,
          subject_id: params[:subjectId],
          classroom_id: params[:classroomId],
          title: params[:title],
          description: params[:description],
          material_type: params[:type] || 'document',
          content: params[:content],
          file_url: params[:fileUrl],
          file_path: params[:filePath],
          published: params.fetch(:published, true)
        )
        json_response(data: material_payload(material, false), message: "Material created successfully", status: :created)
      end

      def update
        require_teacher!
        return if performed?

        attrs = {
          subject_id: params[:subjectId],
          classroom_id: params[:classroomId],
          title: params[:title],
          description: params[:description],
          material_type: params[:type],
          content: params[:content],
          file_url: params[:fileUrl],
          file_path: params[:filePath],
          published: params[:published]
        }.compact

        @material.update!(attrs)
        json_response(data: material_payload(@material, false), message: "Material updated successfully")
      end

      def destroy
        require_teacher!
        return if performed?

        @material.destroy!
        json_response(data: nil, message: "Material deleted successfully")
      end

      def record_view
        require_student!
        return if performed?

        student = current_user.student
        return render_error("Student record not found") unless student

        view = MaterialView.find_or_initialize_by(learning_material: @material, student: student)
        if view.new_record?
          view.viewed_at = Time.current
          view.save!
          @material.increment!(:total_views)
        end
        json_response(data: nil, message: "View recorded")
      end

      def viewers
        views = @material.material_views.includes(student: :classroom).order(viewed_at: :desc)
        data = views.map do |v|
          {
            studentId: v.student_id,
            name: v.student.name,
            nis: v.student.nis,
            classroomName: v.student.classroom&.name,
            viewedAt: v.viewed_at&.iso8601
          }
        end
        json_response(data: data)
      end

      private

      def set_material
        @material = LearningMaterial.find(params[:id])
      end

      def material_payload(m, has_viewed = false)
        {
          id: m.id,
          teacherId: m.teacher_id,
          teacherName: m.teacher&.name,
          subjectId: m.subject_id,
          subjectName: m.subject&.name,
          classroomId: m.classroom_id,
          classroomName: m.classroom&.name,
          title: m.title,
          description: m.description,
          type: m.material_type,
          content: m.content,
          fileUrl: m.file_url,
          filePath: m.file_path,
          published: m.published,
          totalViews: m.total_views,
          hasViewed: has_viewed,
          createdAt: m.created_at&.iso8601
        }
      end
    end
  end
end
