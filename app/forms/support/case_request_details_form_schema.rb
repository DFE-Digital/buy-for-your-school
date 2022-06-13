module Support
  class CaseRequestDetailsFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_migration_form
    include Concerns::RequestDetailsFormFieldsSchema

    params do
      required(:request_text).value(:string)
      optional(:request_type).value(:bool)
      optional(:category_id).value(:string)
      optional(:query_id).value(:string)
      optional(:other_category).value(:string)
      optional(:other_query).value(:string)
    end
  end
end
