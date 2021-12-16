module Support
  class CaseProcurementDetailsFormSchema < Schema
    config.messages.top_namespace = :case_procurement_details_form

    params do
      optional(:required_agreement_type).value(:symbol)
      optional(:route_to_market).value(:symbol)
      optional(:reason_for_route_to_market).value(:symbol)
      optional(:framework_name).value(:string)
      optional(:stage).value(:symbol)
      optional(:started_at).maybe(:date)
      optional(:ended_at).maybe(:date)
    end

    rule(:started_at, :ended_at) do
      key.failure(:before_end_date) if values[:started_at].present? && values[:ended_at].present? && values[:started_at] > values[:ended_at]
    end
  end
end
