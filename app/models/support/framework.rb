# frozen_string_literal: true

module Support
  class Framework < ApplicationRecord
    has_many :procurements, class_name: "Support::Procurement"

    # frameworks that have not expired
    scope :active, -> { where("expires_at > ?", Time.zone.now) }

    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        lower(supplier) LIKE lower(:q) OR
        lower(category) LIKE lower(:q)
      SQL

      active.where(sql, q: "#{query}%").limit(30)
    }
  end
end
