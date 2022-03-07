module Support
  class EditCaseFormSchema < ::Support::Schema
    params do
      optional(:request_text).value(:string)
    end
  end
end
