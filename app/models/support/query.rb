# frozen_string_literal: true

module Support
  #
  # Types of procurement or "categories of spend"
  #
  class Query < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    validates :title, presence: true

    scope :ordered_by_title, -> { order(title: :asc) }

    def self.other_query_id
      find_by(title: "Other")&.id
    end
  end
end
