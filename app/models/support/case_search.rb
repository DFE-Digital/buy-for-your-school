module Support
  class CaseSearch < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"

    scope :omnisearch, lambda { |query|
      find_a_case(query).limit(30)
    }

    scope :find_a_case, lambda { |query|
      sql = <<-SQL
        lower(organisation_name) LIKE :q OR
        lower(case_email) LIKE :q OR
        lower(organisation_urn) LIKE :q OR
        lower(agent_first_name) LIKE :q OR
        lower(agent_last_name) LIKE :q
      SQL

      where("case_ref = ?", sprintf("%06d", query.to_i))
        .or(where(sql, q: "#{query.downcase}%"))
        .order("case_ref DESC")
    }
  end
end
