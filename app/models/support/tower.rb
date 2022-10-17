module Support
  class Tower < ApplicationRecord
    has_many :categories, class_name: "Support::Category", foreign_key: "support_tower_id"
    has_many :cases, through: :categories, class_name: "Support::Case"

    def self.unique_towers
      order(title: :asc).uniq
    end
  end
end
