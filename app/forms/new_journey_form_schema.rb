# Validate new journey form
#
class NewJourneyFormSchema < Schema
  config.messages.top_namespace = :new_journey

  params do
    optional(:category).value(:string)
    optional(:name).value(:string)
  end

  rule(:category) do
    key.failure(:missing) if value.blank?
  end

  rule(:name) do
    key.failure(:missing) if value.blank?
  end

  rule(:name).validate(max_size?: 30)
end
