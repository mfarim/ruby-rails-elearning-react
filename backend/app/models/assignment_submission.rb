class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment
  belongs_to :student

  validates :assignment_id, uniqueness: { scope: :student_id }
  validates :status, inclusion: { in: %w[submitted graded late] }
end
