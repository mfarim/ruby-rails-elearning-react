class Announcement < ApplicationRecord
  validates :title, :content, presence: true
  validates :target, inclusion: { in: %w[all teacher student] }

  scope :published_only, -> { where(published: true) }
end
