module Support
  class CaseSearch < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"

    scope :omnisearch, lambda { |query|
      find_a_case(query).limit(30)
    }

    scope :find_a_case, lambda { |query, exact_match: false|
      comp = exact_match ? "=" : "LIKE"
      query_str = exact_match ? query.downcase : "#{query.downcase}%"

      sql = <<-SQL
        lower(organisation_name) #{comp} :q OR
        lower(case_email) #{comp} :q OR
        lower(organisation_urn) #{comp} :q OR
        lower(agent_first_name) #{comp} :q OR
        lower(agent_last_name) #{comp} :q
      SQL

      where("case_ref = ?", sprintf("%06d", query.to_i))
        .or(where(sql, q: query_str))
        .order("case_ref DESC")
    }
  end
end
