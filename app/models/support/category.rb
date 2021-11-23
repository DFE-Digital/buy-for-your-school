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

    def self.grouped_opts
      top_level.each_with_object({}) do |category, parent_hash|
        parent_hash[category.title] =
          category.sub_categories.each_with_object({}) do |sub_category, child_hash|
            child_hash[sub_category.title] = sub_category.id
          end
      end
    end
  end
end
