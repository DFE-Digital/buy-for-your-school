# Validate user feedback form
#
class DownloadSpecificationFormSchema < Schema
  config.messages.top_namespace = :download_specification

  params do
    optional(:finished).value(:bool)
  end
end
