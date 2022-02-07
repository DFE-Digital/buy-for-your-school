# :nocov:
module Support
  class CaseOrganisationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] organisation_id
    # @return [String]
    option :organisation_id, Types::Params::String, optional: true

    def assign_organisation_to_case(kase)
      kase.update(organisation: Support::Organisation.find(organisation_id))
    end
  end
end
# :nocov:
