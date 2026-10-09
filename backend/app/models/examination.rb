class Examination < ApplicationRecord
  belongs_to :teacher
  belongs_to :subject
  belongs_to :classroom
  has_many :questions, dependent: :destroy
  has_many :exam_attempts, dependent: :destroy

  validates :title, presence: true
  validates :exam_type, inclusion: { in: %w[quiz midterm final tryout] }
  validates :status, inclusion: { in: %w[draft published archived] }
end
