module Support
  class CaseSummaryFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_summary_form
    include Concerns::RequestDetailsFormFieldsSchema

    params do
      optional(:request_type).value(:bool)
      optional(:category_id).value(:string)
      optional(:query_id).value(:string)
      optional(:other_category).value(:string)
      optional(:other_query).value(:string)
      optional(:source).maybe(:string)
      optional(:support_level).maybe(:string)
      optional(:value).maybe(:decimal)
      optional(:procurement_stage_id).value(:string)
    end

    rule(:source) do
      key(:source).failure(:missing) if value.blank?
    end
  end
end
