# frozen_string_literal: true

module Support
  #
  # Types of procurement or "categories of spend"
  #
  class Category < ApplicationRecord
    has_many :cases, class_name: "Support::Case"
    belongs_to :parent, class_name: "Support::Category", optional: true
    has_many :sub_categories, class_name: "Support::Category", foreign_key: "parent_id"

    # TODO: validate all fields in code and at DB layer
    validates :title, presence: true, uniqueness: { scope: :parent_id }
    # validates :description, presence: true
    # validates :slug, presence: true
  end
end
