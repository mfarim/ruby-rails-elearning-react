class LearningMaterial < ApplicationRecord
  belongs_to :teacher
  belongs_to :subject
  belongs_to :classroom, optional: true
  has_many :material_views, dependent: :destroy

  validates :title, presence: true
  validates :material_type, inclusion: { in: %w[document video text link audio] }
end
