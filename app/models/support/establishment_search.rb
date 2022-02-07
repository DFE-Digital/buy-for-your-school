module Support
  class EstablishmentSearch < ApplicationRecord
    scope :omnisearch, -> (query) do
      sql = <<-SQL
        urn LIKE :q OR
        ukprn LIKE :q OR
        lower(name) LIKE lower(:q) OR
        lower(postcode) LIKE lower(:q)
      SQL

      where(sql, q: "#{query}%").limit(30)
    end
  end
end
