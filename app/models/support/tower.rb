module Support
  class Tower < ApplicationRecord
    def self.unique_towers
      order(title: :asc).uniq
    end
  end
end
