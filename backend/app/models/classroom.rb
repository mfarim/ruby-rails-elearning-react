class Classroom < ApplicationRecord
  belongs_to :homeroom_teacher, class_name: 'Teacher', optional: true
  has_many :students, dependent: :nullify
  has_many :learning_materials, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :examinations, dependent: :destroy

  validates :name, presence: true
end
