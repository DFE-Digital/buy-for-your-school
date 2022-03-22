# Validate new journey form
#
class NewJourneyFormSchema < Schema
  config.messages.top_namespace = :new_journey

  params do
    optional(:category).value(:string)
    optional(:name).value(:string, max_size?: 30)
    optional(:step).value(:integer)
  end

  rule(:category) do
    key.failure(:missing) if key? && value.blank?
  end

  rule(:name) do
    key.failure(:missing) if key? && value.blank?
  end
end
