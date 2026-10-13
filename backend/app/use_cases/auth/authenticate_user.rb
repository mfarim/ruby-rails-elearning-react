module Auth
  class AuthenticateUser
    def initialize(user_repo: UserRepository.new)
      @user_repo = user_repo
    end

    def call(email:, password:)
      user = @user_repo.find_by_email(email)

      unless user&.authenticate(password)
        return UseCaseResult.failure("Invalid email or password", status: :unauthorized)
      end

      token = JsonWebToken.encode(user_id: user.id)
      payload = {
        accessToken: token,
        refreshToken: token,
        tokenType: "Bearer",
        userId: user.id,
        name: user.name,
        email: user.email,
        roles: [user.role],
        active: user.active,
        impersonatedBy: user.impersonated_by_id,
        token: token
      }

      UseCaseResult.success(payload)
    end
  end
end
