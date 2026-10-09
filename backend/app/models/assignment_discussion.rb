class AssignmentDiscussion < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
  belongs_to :parent, class_name: 'AssignmentDiscussion', optional: true
  has_many :replies, class_name: 'AssignmentDiscussion', foreign_key: :parent_id, dependent: :destroy

  validates :message, presence: true
end
