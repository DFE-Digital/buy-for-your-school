# frozen_string_literal: true

module Support
  #
  # A public servant who picks up and handles "support cases". This is sometimes
  # referred to as "worker", "case worker" or "proc ops worker" within the business.
  #
  class Agent < ApplicationRecord
    has_many :cases, class_name: "Support::Case"
    belongs_to :support_tower, class_name: "Support::Tower", optional: true
    belongs_to :user, foreign_key: "dsi_uid", primary_key: "dfe_sign_in_uid", optional: true

    scope :caseworkers, -> { where("'procops' = ANY(roles)") }
    scope :internal, -> { where("'internal' = ANY(roles)") }
    scope :by_first_name, -> { order("first_name ASC, last_name ASC") }

    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        lower(first_name) LIKE lower(:q) OR
        lower(last_name) LIKE lower(:q)
      SQL

      caseworkers.where(sql, q: "#{query}%").limit(30)
    }

    def full_name = "#{first_name} #{last_name}"

    def initials = "#{first_name.first}#{last_name.first}"
  end
end
