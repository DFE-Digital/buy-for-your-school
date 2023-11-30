module Frameworks::Framework::Searchable
  extend ActiveSupport::Concern

  included do
    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        lower(name) LIKE lower(:q) OR
        lower(short_name) LIKE lower(:q) OR
        reference = :query
      SQL

      where(sql, q: "%#{query}%", query:).limit(30)
    }
  end
end
