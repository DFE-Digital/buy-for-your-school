module Support
  class CaseProcurementStageChangePresenter < SimpleDelegator
    def body
      from = additional_data["from"]
      to = additional_data["to"]

      "#{agent_full_name} changed procurement stage from #{stage_title(from)} to #{stage_title(to)}"
    end

    def show_additional_data? = false

  private

    def agent_full_name
      agent_id ? Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name : case_owner_name
    end

    def energy_case?
      Energy::OnboardingCase.exists?(support_case_id: case_id)
    end

    def case_owner_name
      return "unknown" unless energy_case?

      kase = Support::Case.find_by(id: case_id)
      kase ? "#{kase.first_name} #{kase.last_name}" : "unknown"
    end

    def stage_title(id)
      return "none" if id.nil?

      procurement_stage = Support::ProcurementStage.find(id)
      "Stage #{procurement_stage.stage} - #{procurement_stage.title}"
    end
  end
end
