module Api
  module V1
    class AnnouncementsController < BaseController
      before_action :set_announcement, only: [:show, :update, :destroy]

      def index
        scope = Announcement.order(created_at: :desc)
        if current_user.student?
          scope = scope.where(target: ['all', 'student'], published: true)
        elsif current_user.teacher?
          scope = scope.where(target: ['all', 'teacher'], published: true)
        end
        data = scope.map { |a| announcement_payload(a) }
        json_response(data: data)
      end

      def show
        json_response(data: announcement_payload(@announcement))
      end

      def create
        require_admin!
        return if performed?

        announcement = Announcement.create!(announcement_params)
        json_response(data: announcement_payload(announcement), message: "Announcement created successfully", status: :created)
      end

      def update
        require_admin!
        return if performed?

        @announcement.update!(announcement_params)
        json_response(data: announcement_payload(@announcement), message: "Announcement updated successfully")
      end

      def destroy
        require_admin!
        return if performed?

        @announcement.destroy!
        json_response(data: nil, message: "Announcement deleted successfully")
      end

      private

      def set_announcement
        @announcement = Announcement.find(params[:id])
      end

      def announcement_params
        params.permit(:title, :content, :target, :published)
      end

      def announcement_payload(a)
        {
          id: a.id,
          title: a.title,
          content: a.content,
          target: a.target,
          published: a.published,
          createdAt: a.created_at&.iso8601
        }
      end
    end
  end
end
