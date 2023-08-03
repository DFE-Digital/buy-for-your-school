module Support
  class CaseWithSchoolChangePresenter < SimpleDelegator
    def body
      if agent_id.present?
        "#{agent_full_name} #{change_type} the 'With School' flag"
      else
        "The 'With School' flag was #{change_type} by the system"
      end
    end

    def show_additional_data? = false

  private

    def change_type = additional_data["to"] == true ? "set" : "cleared"

    def agent_full_name = agent_id.nil? ? "unknown" : Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name
  end
end
