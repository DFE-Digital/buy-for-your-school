module Support
  class CaseProcurementDetailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] required_agreement_type
    #   @return [Symbol, nil]
    option :required_agreement_type, optional: true
    # @!attribute [r] route_to_market
    #   @return [Symbol, nil]
    option :route_to_market, optional: true
    # @!attribute [r] reason_for_route_to_market
    #   @return [Symbol, nil]
    option :reason_for_route_to_market, optional: true
    # @!attribute [r] framework_name
    #   @return [String, nil]
    option :framework_name, optional: true, default: proc { nil }
    # @!attribute [r] started_at
    #   @return [Date, nil]
    option :started_at, optional: true
    # @!attribute [r] ended_at
    #   @return [Date, nil]
    option :ended_at, optional: true
    # @!attribute [r] stage
    #   @return [Symbol, nil]
    option :stage, optional: true
  end
end
