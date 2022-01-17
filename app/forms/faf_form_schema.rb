#
# Validate "find-a-framework support requests"
#
class FafFormSchema < Schema
  params do
    optional(:dsi).value(:bool)
  end

  rule(:dsi) do
    key.failure(:missing) unless key?
  end
end
