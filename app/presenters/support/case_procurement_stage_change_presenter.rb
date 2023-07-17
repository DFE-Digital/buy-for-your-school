module Support
  class CaseProcurementStageChangePresenter < SimpleDelegator
    def body
      from = additional_data["from"]
      to = additional_data["to"]

      "#{agent_full_name} changed procurement stage from #{stage_title(from)} to #{stage_title(to)}"
    end

    def show_additional_data? = false

  private

    def agent_full_name = agent_id.nil? ? "unknown" : Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name

    def stage_title(id)
      return "none" if id.nil?

      procurement_stage = Support::ProcurementStage.find(id)
      "Stage #{procurement_stage.stage} - #{procurement_stage.title}"
    end
  end
end
