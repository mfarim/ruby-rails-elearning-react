class ExamAttempt < ApplicationRecord
  belongs_to :examination
  belongs_to :student
  has_many :exam_answers, dependent: :destroy

  validates :status, inclusion: { in: %w[in_progress submitted needs_grading completed] }
end
