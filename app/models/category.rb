# Top-level entity within Contentful CMS
#
class Category < ApplicationRecord
  has_many :journeys, dependent: :destroy

  validates :title, :description, :contentful_id, :liquid_template, :slug, presence: true
  # TODO: re-enable when no longer clashes with data migrations
  # validates :slug, presence: true
  validates :contentful_id, uniqueness: true
end
