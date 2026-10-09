class Question < ApplicationRecord
  belongs_to :examination
  has_many :exam_answers, dependent: :destroy

  validates :question_text, presence: true
  validates :question_type, inclusion: { in: %w[multiple_choice essay true_false] }
  validates :difficulty, inclusion: { in: %w[easy medium hard] }
end
