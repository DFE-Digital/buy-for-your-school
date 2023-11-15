class TicketSearch < ApplicationRecord
  scope :omnisearch, lambda { |query|
    find_ticket(query).limit(30)
  }

  scope :find_ticket, lambda { |query|
    sql = <<-SQL
      lower(reference) LIKE :q OR
      lower(organisation_name) LIKE :q OR
      lower(organisation_urn) LIKE :q OR
      lower(agent_first_name) LIKE :q OR
      lower(agent_last_name) LIKE :q
    SQL

    where("reference = ?", sprintf("%06d", query.to_i))
      .or(where(sql, q: "#{query.downcase}%"))
      .order("reference DESC")
  }
end
