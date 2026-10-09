class MaterialView < ApplicationRecord
  belongs_to :learning_material
  belongs_to :student

  validates :viewed_at, presence: true
  validates :learning_material_id, uniqueness: { scope: :student_id }
end
