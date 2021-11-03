# frozen_string_literal: true

module Support
  #
  # Types of procurement or "categories of spend"
  #
  class Category < ApplicationRecord
    has_many :cases, class_name: "Support::Case"
    belongs_to :parent, class_name: "Support::Category", optional: true
    has_many :sub_categories, class_name: "Support::Category", foreign_key: "parent_id"

    # Disabled due to https://github.com/rubocop/rubocop-rails/issues/231
    validates :title, presence: true, uniqueness: { scope: :parent_id }
    # TODO: validate all fields in code and at DB layer
    # validates :description, presence: true
    # validates :slug, presence: true

    scope :top_level, -> { where(parent_id: nil) }
    scope :ordered_by_title, -> { order(title: :asc) }
  end
end
