module Api
  module V1
    class ClassroomsController < BaseController
      before_action :set_classroom, only: [:show, :update, :destroy]

      def index
        classrooms = classroom_repository.list_with_homeroom
        data = classrooms.map { |c| classroom_payload(c) }
        json_response(data: data)
      end

      def show
        json_response(data: classroom_payload(@classroom))
      end

      def create
        require_admin!
        return if performed?

        classroom = classroom_repository.create!(classroom_params)
        json_response(data: classroom_payload(classroom), message: "Classroom created successfully", status: :created)
      end

      def update
        require_admin!
        return if performed?

        @classroom.update!(classroom_params)
        json_response(data: classroom_payload(@classroom), message: "Classroom updated successfully")
      end

      def destroy
        require_admin!
        return if performed?

        classroom_repository.delete!(@classroom.id)
        json_response(data: nil, message: "Classroom deleted successfully")
      end

      private

      def classroom_repository
        @classroom_repository ||= ClassroomRepository.new
      end

      def set_classroom
        @classroom = classroom_repository.find(params[:id])
      end

      def classroom_params
        params.require(:classroom).permit(:name, :level, :capacity, :academic_year, :homeroom_teacher_id)
      end

      def classroom_payload(c)
        {
          id: c.id,
          name: c.name,
          level: c.level,
          capacity: c.capacity,
          academicYear: c.academic_year,
          homeroomTeacherId: c.homeroom_teacher_id,
          homeroomTeacherName: c.homeroom_teacher&.name,
          createdAt: c.created_at&.iso8601
        }
      end
    end
  end
end
