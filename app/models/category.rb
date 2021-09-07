# Top-level entity within Contentful CMS
#
class Category < ApplicationRecord
  has_many :journeys, dependent: :destroy

  validates :title, :description, :contentful_id, :liquid_template, :slug, presence: true
  # TODO: check to be removed; this is for migration tests that rollback to a schema without slug
  validates :slug, presence: true, if: -> { Category.column_names.include?("slug") }
  validates :contentful_id, uniqueness: true
end
