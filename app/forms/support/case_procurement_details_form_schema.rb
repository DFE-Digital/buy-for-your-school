module Support
  class CaseProcurementDetailsFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_procurement_details_form

    params do
      optional(:required_agreement_type).value(:symbol)
      optional(:route_to_market).value(:symbol)
      optional(:reason_for_route_to_market).value(:symbol)
      optional(:frameworks_framework_id).value(:string)
      optional(:framework_id).value(:string)
      optional(:started_at).value(:hash)
      optional(:ended_at).value(:hash)
    end

    rule :started_at do
      # optional
      key.failure(:invalid) unless value.values.all?(&:blank?) || hash_to_date.call(value)
    end

    rule :ended_at do
      # optional
      key.failure(:invalid) unless value.values.all?(&:blank?) || hash_to_date.call(value)
    end

    rule(:started_at, :ended_at) do
      started_at_date = hash_to_date.call(values[:started_at])
      ended_at_date = hash_to_date.call(values[:ended_at])
      key.failure(:before_end_date) if started_at_date.present? && ended_at_date.present? && started_at_date > ended_at_date
    end
  end
end
