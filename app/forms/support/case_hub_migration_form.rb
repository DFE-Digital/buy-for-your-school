module Support
  class CaseHubMigrationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :school_urn, optional: true
    option :contact_name, optional: true
    option :contact_email, optional: true
    option :contact_phone_number, optional: true
    option :buying_category, optional: true
    option :hub_case_ref, optional: true
    option :estimated_procurement_completion_date, optional: true
    option :estimated_savings, optional: true
    option :hub_notes, optional: true
    option :progress_notes, optional: true

    def case_type
      "NW Hub Case"
    end

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.attributes(self)
    end
  end
end
