module Api
  module V1
    class SubjectsController < BaseController
      before_action :set_subject, only: [:show, :update, :destroy]

      def index
        subjects = Subject.includes(:teacher).order(:name)
        data = subjects.map { |s| subject_payload(s) }
        json_response(data: data)
      end

      def show
        json_response(data: subject_payload(@subject))
      end

      def create
        require_admin!
        return if performed?

        subject = Subject.create!(subject_params)
        json_response(data: subject_payload(subject), message: "Subject created successfully", status: :created)
      end

      def update
        require_admin!
        return if performed?

        @subject.update!(subject_params)
        json_response(data: subject_payload(@subject), message: "Subject updated successfully")
      end

      def destroy
        require_admin!
        return if performed?

        @subject.destroy!
        json_response(data: nil, message: "Subject deleted successfully")
      end

      private

      def set_subject
        @subject = Subject.find(params[:id])
      end

      def subject_params
        params.require(:subject).permit(:name, :code, :description, :teacher_id, :credits)
      end

      def subject_payload(s)
        {
          id: s.id,
          name: s.name,
          code: s.code,
          description: s.description,
          teacherId: s.teacher_id,
          teacherName: s.teacher&.name,
          credits: s.credits,
          createdAt: s.created_at&.iso8601
        }
      end
    end
  end
end
