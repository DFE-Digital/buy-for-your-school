# frozen_string_literal: true

module Support
  class CreateCaseForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :organisation_id, optional: true
    option :organisation_type, optional: true
    option :organisation_name, optional: true
    option :organisation_urn, optional: true
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
    option :request_type, Types::Params::Bool | Types.Constructor(::TrueClass, &:present?), optional: true

    # @see Support::Case#source
    # @return [String]
    def case_type
      return if hub_case_ref.blank?

      if north_west_check
        "nw_hub"
      elsif south_west_check
        "sw_hub"
      end
    end

    # @return [Hash] form parms
    def to_h
      self.class.dry_initializer.attributes(self)
          .except(:messages, :request_type)
          .merge(source: case_type)
          .compact
    end

    # @return [Boolean]
    def request_type?
      instance_variable_get :@request_type
    end

  private

    def north_west_check
      hub_case_ref.to_i.between?(1000, 99_999)
    end

    def south_west_check
      hub_case_ref.downcase.start_with?("ce-")
    end
  end
end
