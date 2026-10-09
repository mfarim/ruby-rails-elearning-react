class Teacher < ApplicationRecord
  belongs_to :user
  has_many :classrooms, foreign_key: :homeroom_teacher_id, dependent: :nullify
  has_many :subjects, dependent: :nullify
  has_many :learning_materials, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :examinations, dependent: :destroy

  validates :nip, presence: true, uniqueness: true
  validates :name, :email, presence: true
end
