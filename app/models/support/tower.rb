module Support
  class Tower < ApplicationRecord
    has_many :categories, class_name: "Support::Category", foreign_key: "support_tower_id"
    has_many :cases, through: :categories, class_name: "Support::Case"

    def self.unique_towers
      order(title: :asc).uniq
    end

    def self.nil_tower
      OpenStruct.new(title: "No Tower", categories: Support::Category, cases: Support::Case.without_tower)
    end
  end
end
