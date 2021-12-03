module Support
  class CaseProcurementDetailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] procurement_id
    # @return [String]
    # option :procurement_id, Types::Params::String
    option :required_agreement_type, optional: true
    option :route_to_market, optional: true
    option :reason_for_route_to_market, optional: true
    option :framework_name, optional: true
    option :started_at, optional: true
    option :ended_at, optional: true
    option :stage, optional: true
  end
end
