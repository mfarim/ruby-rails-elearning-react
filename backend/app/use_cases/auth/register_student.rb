module Auth
  class RegisterStudent
    def initialize(user_repo: UserRepository.new)
      @user_repo = user_repo
    end

    def call(name:, email:, password:, nis: nil, gender: 'M')
      user = nil
      ActiveRecord::Base.transaction do
        user = User.create!(
          name: name,
          email: email,
          password: password,
          role: 'ROLE_STUDENT',
          active: true
        )

        nis_code = nis.presence || "NIS#{Time.current.to_i % 1000000}"
        Student.create!(
          user: user,
          name: user.name,
          email: user.email,
          nis: nis_code,
          gender: gender.presence || 'M',
          active: true
        )
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
        token: token
      }

      UseCaseResult.success(payload, status: :created)
    rescue ActiveRecord::RecordInvalid => e
      UseCaseResult.failure(e.message, status: :unprocessable_entity, errors: e.record.errors.as_json)
    rescue StandardError => e
      UseCaseResult.failure(e.message, status: :bad_request)
    end
  end
end
