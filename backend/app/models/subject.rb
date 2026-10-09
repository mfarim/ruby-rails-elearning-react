class Subject < ApplicationRecord
  belongs_to :teacher, optional: true
  has_many :learning_materials, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :examinations, dependent: :destroy

  validates :name, :code, presence: true
  validates :code, uniqueness: true
end
