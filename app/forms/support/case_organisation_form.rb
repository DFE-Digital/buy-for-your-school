module Support
  class CaseOrganisationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] organisation_formatted_name
    # @return [String]
    option :organisation_formatted_name, Types::Params::String, optional: true

    def assign_organisation_to_case(kase)
      kase.update(organisation: Support::Organisation.find_by_formatted_name(organisation_formatted_name))
    end
  end
end
