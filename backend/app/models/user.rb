class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[ROLE_ADMIN ROLE_TEACHER ROLE_STUDENT] }

  has_one :teacher, dependent: :destroy
  has_one :student, dependent: :destroy
  has_many :assignment_discussions, dependent: :destroy

  def admin?
    role == 'ROLE_ADMIN'
  end

  def teacher?
    role == 'ROLE_TEACHER'
  end

  def student?
    role == 'ROLE_STUDENT'
  end

  def profile_data
    if teacher? && teacher.present?
      {
        nip: teacher.nip,
        phone: teacher.phone,
        address: teacher.address,
        photo: teacher.photo
      }
    elsif student? && student.present?
      {
        nis: student.nis,
        nisn: student.nisn,
        phone: student.phone,
        gender: student.gender,
        birthDate: student.birth_date&.to_s,
        address: student.address,
        photo: student.photo,
        classroomId: student.classroom_id,
        classroomName: student.classroom&.name
      }
    else
      {}
    end
  end
end
