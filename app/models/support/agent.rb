# frozen_string_literal: true

module Support
  #
  # A public servant who picks up and handles "support cases". This is sometimes
  # referred to as "worker", "case worker" or "proc ops worker" within the business.
  #
  class Agent < ApplicationRecord
    include Notifyable
    include RoleAssignable

    has_many :cases, class_name: "Support::Case"
    has_many :live_cases, -> { live }, class_name: "Support::Case"
    belongs_to :support_tower, class_name: "Support::Tower", optional: true
    belongs_to :user, foreign_key: "dsi_uid", primary_key: "dfe_sign_in_uid", optional: true

    scope :caseworkers, -> { by_role(%w[procops procops_admin]) }
    scope :non_caseworkers, -> { caseworkers.invert_where }
    scope :e_and_o_staff, -> { by_role(%w[e_and_o e_and_o_admin]) }
    scope :by_first_name, -> { order("first_name ASC, last_name ASC") }
    scope :disabled, -> { where("roles::text = '{}'::text") }
    scope :enabled, -> { disabled.invert_where }
    scope :with_cases, -> { where.associated(:cases).distinct }
    scope :with_live_cases, -> { where.associated(:live_cases).distinct }

    validates :email, uniqueness: { case_sensitive: false }

    before_validation :normalize_email

    scope :omnisearch, lambda { |query|
      sql = <<-SQL
        lower(first_name) LIKE lower(:q) OR
        lower(last_name) LIKE lower(:q)
      SQL

      caseworkers.where(sql, q: "#{query}%").limit(30)
    }

    def self.find_or_create_by_full_name(full_name)
      first_name, last_name = String(full_name).split(" ")

      return nil if first_name.blank? || last_name.blank?

      find_or_create_by!(first_name:, last_name:)
    end

    def self.find_or_create_by_user(user)
      agent = find_by(dsi_uid: user.dfe_sign_in_uid)

      return agent unless agent.nil? && user.proc_ops?

      find_or_create_by!(dsi_uid: user.dfe_sign_in_uid) do |new_agent|
        new_agent.email = user.email
        new_agent.first_name = user.first_name
        new_agent.last_name = user.last_name
      end
    end

    def full_name = "#{first_name} #{last_name}"

    def initials = "#{first_name.first}#{last_name.first}"

  private

    def normalize_email
      email&.downcase!
    end
  end
end
