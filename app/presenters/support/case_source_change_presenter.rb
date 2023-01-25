module Support
  class CaseSourceChangePresenter < SimpleDelegator
    def body
      from = additional_data["from"]
      to = additional_data["to"]

      "#{agent_full_name} changed source from #{source_title(from)} to #{source_title(to)}"
    end

  private

    def agent_full_name = agent_id.nil? ? "unknown" : Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name
    def source_title(source) = I18n.t("support.case.label.source.#{source}")
  end
end
