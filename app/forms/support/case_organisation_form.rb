# :nocov:
module Support
  class CaseOrganisationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :establishment_id, Types::Params::String, optional: true

    def assign_organisation_to_case(kase)
      kase.update(organisation: Support::Organisation.find(establishment_id))
    end
  end
end
# :nocov:
