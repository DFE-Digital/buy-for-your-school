# :nocov:
module Support
  class CaseSearchFormSchema < CaseFilterFormSchema
    config.messages.top_namespace = :case_search_form

    params do
      required(:search_term).value(:string)
    end

    rule(:search_term).validate(min_size?: 2)
  end
end
# :nocov:
