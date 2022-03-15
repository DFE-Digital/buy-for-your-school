module Support
  class CaseSearch < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"

    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        case_ref LIKE :q OR
        lower(organisation_name) LIKE lower(:q) OR
        lower(organisation_urn) LIKE lower(:q) OR
        lower(agent_first_name) LIKE lower(:q) OR
        lower(agent_last_name) LIKE lower(:q)
      SQL

      where(sql, q: "#{query}%").limit(30)
    }

    scope :find_a_case, lambda { |query|
      sql = <<-SQL
        case_ref LIKE :q OR
        lower(organisation_name) LIKE '%' || lower(:q) || '%' OR
        lower(organisation_urn) LIKE lower(:q) OR
        lower(agent_first_name) LIKE lower(:q) OR
        lower(agent_last_name) LIKE lower(:q)
      SQL

      where(sql, q: "#{query}%")
    }
  end
end
