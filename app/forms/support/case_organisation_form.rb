# :nocov:
module Support
  class CaseOrganisationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :organisation_id, Types::Params::String, optional: true
    option :organisation_type, Types::Params::String, optional: true

    def assign_organisation_to_case(kase)
      kase.update(organisation_id:, organisation_type:)
    end
  end
end
# :nocov:
