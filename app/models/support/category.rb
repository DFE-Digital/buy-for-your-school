# frozen_string_literal: true

module Support
  #
  # Types of procurement or "categories of spend"
  #
  class Category < ApplicationRecord
    belongs_to :tower, class_name: "Support::Tower", foreign_key: "support_tower_id", optional: true
    has_many :cases, class_name: "Support::Case"
    belongs_to :parent, class_name: "Support::Category", optional: true
    has_many :sub_categories,
             -> { order(Arel.sql("CASE WHEN support_categories.title = 'Not yet known' THEN 2 WHEN support_categories.title LIKE 'Other (%' THEN 1 ELSE 0 END ASC, support_categories.title ASC")) },
             class_name: "Support::Category",
             foreign_key: "parent_id"
    has_many :request_for_help_categories, foreign_key: "support_category_id"

    # Disabled due to https://github.com/rubocop/rubocop-rails/issues/231
    validates :title, presence: true, uniqueness: { scope: :parent_id }
    # TODO: validate all fields in code and at DB layer
    # validates :description, presence: true
    # validates :slug, presence: true

    scope :top_level, -> { where(parent_id: nil) }
    scope :sub_categories, -> { where.not(parent_id: nil) }
    scope :ordered_by_title, -> { order(Arel.sql("case when support_categories.title = 'Or' then 1 else 0 end ASC, support_categories.title ASC")) }
    scope :except_for, ->(title) { where.not(title:) }
    scope :active, -> { where(archived: false) }

    delegate :title, to: :tower, prefix: true, allow_nil: true

    def self.other_category_id
      find_by(title: "Or")
        .sub_categories
        .find_by(title: "Other (General)")
        .id
    end

    def self.change_sub_category_parent!(sub_category_title:, new_parent_category_title:)
      sub_category = sub_categories.find_by(title: sub_category_title)
      new_parent_category = find_by(title: new_parent_category_title)
      sub_category.update!(parent: new_parent_category)
    end

    def is_energy_or_services?
      request_for_help_categories.first&.is_energy_or_services?
    end
  end
end
