module Support
  class CaseCategorisationChangePresenter < SimpleDelegator
    def body
      from = additional_data["from"]
      to = additional_data["to"]

      case additional_data["type"]&.to_sym
      when :category
        "#{agent_full_name} changed category from #{category_title(from)} to #{category_title(to)}"
      when :query
        "#{agent_full_name} changed query type from #{query_title(from)} to #{query_title(to)}"
      when :category_to_query
        "#{agent_full_name} changed case from category #{category_title(from)} to a query of #{query_title(to)}"
      when :query_to_category
        "#{agent_full_name} changed case from query #{query_title(from)} to a category of #{category_title(to)}"
      end
    end

  private

    def category_title(id) = id.nil? ? "none" : Support::Category.find(id).title
    def query_title(id) = id.nil? ? "none" : Support::Query.find(id).title
    def agent_full_name = agent_id.nil? ? "unknown" : Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name
  end
end
