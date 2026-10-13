class UserRepository < BaseRepository
  def initialize
    super(User)
  end

  def find_by_email(email)
    model_class.find_by(email: email)
  end

  def find_admin
    model_class.find_by(role: 'ROLE_ADMIN')
  end
end
