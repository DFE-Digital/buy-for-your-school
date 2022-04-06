# frozen_string_literal: true

module Support
  #
  # A public servant who picks up and handles "support cases". This is sometimes
  # referred to as "worker", "case worker" or "proc ops worker" within the business.
  #
  class Agent < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    # agents that are not internal team members (genuine caseworkers)
    scope :caseworkers, -> { where(internal: false) }

    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        lower(first_name) LIKE lower(:q) OR
        lower(last_name) LIKE lower(:q)
      SQL

      caseworkers.where(sql, q: "#{query}%").limit(30)
    }
  end
end
