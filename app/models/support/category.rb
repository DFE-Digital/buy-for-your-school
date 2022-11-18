# frozen_string_literal: true

module Support
  #
  # Types of procurement or "categories of spend"
  #
  class Category < ApplicationRecord
    belongs_to :tower, class_name: "Support::Tower", foreign_key: "support_tower_id", optional: true
    has_many :cases, class_name: "Support::Case"
    belongs_to :parent, class_name: "Support::Category", optional: true
    has_many :sub_categories, class_name: "Support::Category", foreign_key: "parent_id"

    # Disabled due to https://github.com/rubocop/rubocop-rails/issues/231
    validates :title, presence: true, uniqueness: { scope: :parent_id }
    # TODO: validate all fields in code and at DB layer
    # validates :description, presence: true
    # validates :slug, presence: true

    scope :top_level, -> { where(parent_id: nil) }
    scope :sub_categories, -> { where.not(parent_id: nil) }
    scope :ordered_by_title, -> { order(title: :asc) }
    scope :except_for, ->(title) { where.not(title:) }
    scope :active, -> { where(archived: false) }

    def self.other_category_id
      find_by(title: "Or")
        .sub_categories
        .find_by(title: "Other")
        .id
    end

    def tower_title
      tower&.title
    end
  end
end
