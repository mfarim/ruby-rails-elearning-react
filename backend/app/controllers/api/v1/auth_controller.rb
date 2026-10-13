module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:login, :register]

      def login
        result = authenticate_user_use_case.call(
          email: params[:email],
          password: params[:password]
        )
        handle_result(result, message: "Login successful")
      end

      def register
        result = register_student_use_case.call(
          name: params[:name],
          email: params[:email],
          password: params[:password],
          nis: params[:nis],
          gender: params[:gender]
        )
        handle_result(result, message: "Registration successful")
      end

      def me
        profile_response = {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
          roles: [current_user.role],
          active: current_user.active,
          impersonatedBy: current_user.impersonated_by_id,
          profile: current_user.profile_data
        }
        json_response(data: profile_response)
      end

      def impersonate
        require_admin!
        return if performed?

        target_user = user_repository.find(params[:user_id])
        token = JsonWebToken.encode(user_id: target_user.id)
        payload = build_auth_payload(target_user, token, impersonated_by: current_user.id)
        json_response(data: payload, message: "Impersonation started successfully")
      end

      def stop_impersonate
        admin_user = user_repository.find_admin || current_user
        token = JsonWebToken.encode(user_id: admin_user.id)
        payload = build_auth_payload(admin_user, token)
        json_response(data: payload, message: "Returned to admin session")
      end

      private

      def user_repository
        @user_repository ||= UserRepository.new
      end

      def authenticate_user_use_case
        @authenticate_user_use_case ||= Auth::AuthenticateUser.new(user_repo: user_repository)
      end

      def register_student_use_case
        @register_student_use_case ||= Auth::RegisterStudent.new(user_repo: user_repository)
      end

      def build_auth_payload(user, token, impersonated_by: nil)
        {
          accessToken: token,
          refreshToken: token,
          tokenType: "Bearer",
          userId: user.id,
          name: user.name,
          email: user.email,
          roles: [user.role],
          active: user.active,
          impersonatedBy: impersonated_by || user.impersonated_by_id,
          token: token
        }
      end
    end
  end
end
