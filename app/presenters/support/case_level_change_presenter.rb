module Support
  class CaseLevelChangePresenter < SimpleDelegator
    def body
      from = additional_data["from"]
      to = additional_data["to"]

      "#{agent_full_name} changed support level from #{from} to #{to}"
    end

    def show_additional_data? = false

  private

    def agent_full_name = agent_id.nil? ? "unknown" : Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name
  end
end
