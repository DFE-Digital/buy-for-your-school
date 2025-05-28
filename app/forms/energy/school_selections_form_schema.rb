# Validate School Selection Form
#
class Energy::SchoolSelectionsFormSchema < Schema
  config.messages.top_namespace = :school_selection_form

  params do
    required(:select_school).value(:string)
  end

  rule(:select_school) do
    key.failure(:missing) if value.blank?
  end
end
