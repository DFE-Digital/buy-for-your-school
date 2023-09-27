module CaseManagement
  class AssignOrganisationToCase
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, organisation_id:, organisation_type:)
      support_case = Support::Case.find(support_case_id)
      support_case.case_organisations.destroy_all
      support_case.organisation_id = organisation_id
      support_case.organisation_type = organisation_type
      support_case.save!

      broadcast(:case_organisation_changed, { case_id: support_case_id, agent_id:, organisation_id: })
    end
  end
end
