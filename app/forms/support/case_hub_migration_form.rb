# frozen_string_literal: true

module Support
  class CaseHubMigrationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :school_urn, optional: true
    option :organisation_id, optional: true
    option :first_name, optional: true
    option :last_name, optional: true
    option :email, optional: true
    option :phone_number, optional: true
    option :category_id, optional: true
    option :hub_case_ref, optional: true
    option :estimated_procurement_completion_date, optional: true
    option :estimated_savings, optional: true
    option :hub_notes, optional: true
    option :progress_notes, optional: true

    # @see Support::Case#source
    # @return [String]
    def case_type
      return if hub_case_ref.nil?

      hub_case_ref.downcase.start_with?("ce-") ? "sw_hub" : "nw_hub"
    end

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.attributes(self)
          .except(:messages)
          .merge(source: case_type)
          .compact
    end
  end
end
