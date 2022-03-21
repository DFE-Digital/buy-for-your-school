# Validate edit journey form
#
class EditJourneyFormSchema < Schema
  config.messages.top_namespace = :edit_journey

  params do
    optional(:name).value(:string, max_size?: 30)
  end

  rule(:name) do
    key.failure(:missing) if key? && value.blank?
  end
end
