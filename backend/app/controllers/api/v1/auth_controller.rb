module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:login, :register]

      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          json_response(data: build_auth_payload(user, token), message: "Login successful")
        else
          render_error("Invalid email or password", status: :unauthorized)
        end
      end

      def register
        User.transaction do
          user = User.create!(
            name: params[:name],
            email: params[:email],
            password: params[:password],
            role: 'ROLE_STUDENT',
            active: true
          )

          nis = params[:nis].presence || "NIS#{Time.current.to_i % 1000000}"
          Student.create!(
            user: user,
            name: user.name,
            email: user.email,
            nis: nis,
            gender: params[:gender].presence || 'M',
            active: true
          )

          token = JsonWebToken.encode(user_id: user.id)
          json_response(data: build_auth_payload(user, token), message: "Registration successful", status: :created)
        end
      rescue ActiveRecord::RecordInvalid => e
        render_error(e.message, status: :unprocessable_entity)
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

        target_user = User.find(params[:user_id])
        token = JsonWebToken.encode(user_id: target_user.id)
        payload = build_auth_payload(target_user, token, impersonated_by: current_user.id)
        json_response(data: payload, message: "Impersonation started successfully")
      end

      def stop_impersonate
        admin_user = User.find_by(role: 'ROLE_ADMIN') || current_user
        token = JsonWebToken.encode(user_id: admin_user.id)
        payload = build_auth_payload(admin_user, token)
        json_response(data: payload, message: "Returned to admin session")
      end

      private

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
