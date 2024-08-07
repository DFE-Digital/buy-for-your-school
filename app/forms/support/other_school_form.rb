# :nocov:
module Support
  class OtherSchoolForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :school_id, Types::Params::String, optional: true
    option :organisation_name, Types::Params::String, optional: true

    def assign_organisation_to_case(kase, agent_id)
      CaseManagement::AssignOrganisationToCase.new.call(
        support_case_id: kase.id,
        agent_id:,
        organisation_id:,
        organisation_type:,
      )
    end
  end
end
# :nocov:
