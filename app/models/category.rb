# Top-level entity within Contentful CMS
#
class Category < ApplicationRecord
  has_many :journeys, dependent: :destroy

  validates :title, :contentful_id, :liquid_template, presence: true
end
