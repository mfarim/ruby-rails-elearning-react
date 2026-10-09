module Api
  module V1
    class TeachersController < BaseController
      before_action :set_teacher, only: [:show, :update, :destroy]

      def index
        teachers = Teacher.order(:name)
        data = teachers.map { |t| teacher_payload(t) }
        json_response(data: data)
      end

      def show
        json_response(data: teacher_payload(@teacher))
      end

      def create
        require_admin!
        return if performed?

        Teacher.transaction do
          user = User.create!(
            name: params[:name],
            email: params[:email],
            password: params[:password].presence || 'password123',
            role: 'ROLE_TEACHER',
            active: true
          )

          teacher = Teacher.create!(
            user: user,
            nip: params[:nip],
            name: params[:name],
            email: params[:email],
            phone: params[:phone],
            address: params[:address],
            photo: params[:photo],
            active: params.fetch(:active, true)
          )

          json_response(data: teacher_payload(teacher), message: "Teacher created successfully", status: :created)
        end
      end

      def update
        require_admin!
        return if performed?

        @teacher.update!(teacher_update_params)
        @teacher.user.update!(name: @teacher.name, email: @teacher.email) if @teacher.user
        json_response(data: teacher_payload(@teacher), message: "Teacher updated successfully")
      end

      def destroy
        require_admin!
        return if performed?

        user = @teacher.user
        @teacher.destroy!
        user&.destroy!
        json_response(data: nil, message: "Teacher deleted successfully")
      end

      private

      def set_teacher
        @teacher = Teacher.find(params[:id])
      end

      def teacher_update_params
        params.permit(:nip, :name, :email, :phone, :address, :photo, :active)
      end

      def teacher_payload(t)
        {
          id: t.id,
          userId: t.user_id,
          nip: t.nip,
          name: t.name,
          email: t.email,
          phone: t.phone,
          address: t.address,
          photo: t.photo,
          active: t.active,
          createdAt: t.created_at&.iso8601
        }
      end
    end
  end
end
