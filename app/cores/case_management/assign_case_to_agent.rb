module CaseManagement
  class AssignCaseToAgent
    include Wisper::Publisher

    def call(support_case_id:, assigned_by_agent_id:, assigned_to_agent_id:)
      support_case = Support::Case.find(support_case_id)
      support_case.update!(agent_id: assigned_to_agent_id)

      broadcast(:agent_assigned_to_case, { support_case_id:, assigned_by_agent_id:, assigned_to_agent_id: })
    end
  end
end
