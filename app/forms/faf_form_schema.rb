#
# Validate "find-a-framework support requests"
#
class FafFormSchema < BaseSchema
  params do
    optional(:dsi).value(:bool)
  end

  rule(:dsi) do
    key.failure(:missing) unless key?
  end
end
