module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid

      attr_reader :current_user

      protected

      def authenticate_user!
        header = request.headers['Authorization']
        token = header.split(' ').last if header.present?
        decoded = JsonWebToken.decode(token) if token

        if decoded && (@current_user = User.find_by(id: decoded[:user_id]))
          @current_user
        else
          render_error("Unauthorized: Please log in to continue", status: :unauthorized)
        end
      end

      def require_admin!
        return if performed?
        render_error("Forbidden: Admin access required", status: :forbidden) unless @current_user&.admin?
      end

      def require_teacher!
        return if performed?
        render_error("Forbidden: Teacher or Admin access required", status: :forbidden) unless @current_user&.teacher? || @current_user&.admin?
      end

      def require_student!
        return if performed?
        render_error("Forbidden: Student access required", status: :forbidden) unless @current_user&.student? || @current_user&.admin?
      end

      def handle_result(result, message: "Success")
        if result.success?
          json_response(data: result.data, message: message, status: result.status)
        else
          render_error(result.error, status: result.status, errors: result.errors)
        end
      end

      def json_response(data: nil, message: "Success", status: :ok, errors: nil)
        camelized_data = camelize_keys(data.as_json)

        render json: {
          success: [:ok, :created, 200, 201].include?(status),
          message: message,
          data: camelized_data,
          errors: errors,
          timestamp: Time.current.iso8601
        }, status: status
      end

      def render_error(message, status: :bad_request, errors: nil)
        render json: {
          success: false,
          message: message,
          data: nil,
          errors: errors,
          timestamp: Time.current.iso8601
        }, status: status
      end

      def handle_not_found(exception)
        render_error(exception.message, status: :not_found)
      end

      def handle_record_invalid(exception)
        render_error(exception.record.errors.full_messages.join(", "), status: :unprocessable_entity, errors: exception.record.errors.as_json)
      end

      def camelize_keys(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k, v), result|
            result[k.to_s.camelize(:lower)] = camelize_keys(v)
          end
        when Array
          obj.map { |item| camelize_keys(item) }
        else
          obj
        end
      end
    end
  end
end
