module Frameworks::Framework::FafImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_faf(framework_details)
      framework = find_or_initialize_by(provider_reference: framework_details.provider_reference)

      provider = Frameworks::Provider.find_or_create_by!(name: framework_details.provider_name)

      framework.update!(
        status: :dfe_approved,
        name: framework_details.name,
        provider_url: framework_details.provider_url,
        ends_at: framework_details.ends_at,
        description: framework_details.description,
        published_on_faf: true,
        provider:,
      )
    end
  end
end
