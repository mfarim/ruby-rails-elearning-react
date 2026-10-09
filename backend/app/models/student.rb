class Student < ApplicationRecord
  belongs_to :user
  belongs_to :classroom, optional: true
  has_many :material_views, dependent: :destroy
  has_many :assignment_submissions, dependent: :destroy
  has_many :exam_attempts, dependent: :destroy

  validates :nis, presence: true, uniqueness: true
  validates :name, :email, presence: true
  validates :gender, inclusion: { in: %w[M F] }
end
