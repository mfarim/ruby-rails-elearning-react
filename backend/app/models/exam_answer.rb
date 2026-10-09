class ExamAnswer < ApplicationRecord
  belongs_to :exam_attempt
  belongs_to :question

  validates :question_id, uniqueness: { scope: :exam_attempt_id }
end
