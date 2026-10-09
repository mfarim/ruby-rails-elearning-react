class Assignment < ApplicationRecord
  belongs_to :teacher
  belongs_to :subject
  belongs_to :classroom
  has_many :submissions, class_name: 'AssignmentSubmission', dependent: :destroy
  has_many :discussions, class_name: 'AssignmentDiscussion', dependent: :destroy

  validates :title, :due_date, presence: true
end
