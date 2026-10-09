class JsonWebToken
  SECRET_KEY = ENV.fetch("SECRET_KEY") { Rails.application.secret_key_base || "ruby-rails-elearning-secret-key-2026-super-secure" }

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end
