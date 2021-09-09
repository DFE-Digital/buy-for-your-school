# frozen_string_literal: true

module Support
  #
  # Types of procurement or "categories of spend"
  #
  class Category < ApplicationRecord
    has_many :cases, class_name: "Support::Case"
    has_many :sub_categories, class_name: "Support::SubCategory"

    # TODO: validate all fields in code and at DB layer
    validates :title, presence: true
    # validates :description, presence: true
    # validates :slug, presence: true
  end
end
