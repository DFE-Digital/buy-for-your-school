module CaseManagement
  class AssignOrganisationToCase
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, organisation_id:, organisation_type:)
      support_case = Support::Case.find(support_case_id)
      support_case.update!(organisation_id:, organisation_type:)

      broadcast(:case_organisation_changed, { case_id: support_case_id, agent_id:, organisation_id: })
    end
  end
end
