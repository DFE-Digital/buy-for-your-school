module Support
  class CaseNextKeyDateChangePresenter < SimpleDelegator
    def body
      result = "#{agent_full_name} #{change_type} the next key date"
      result += " to #{new_set}" if change_type == "set"

      result
    end

    def show_additional_data? = false

  private

    def change_type = next_key_date.blank? && next_key_date_description.blank? ? "cleared" : "set"

    def next_key_date
      Date.parse(additional_data["next_key_date"]).strftime("%d/%m/%Y")
    rescue TypeError
      nil
    end

    def next_key_date_description = additional_data["next_key_date_description"]

    def new_set = "#{next_key_date} - '#{next_key_date_description}'"

    def agent_full_name = agent_id.nil? ? "unknown" : Support::AgentPresenter.new(Support::Agent.find(agent_id)).full_name
  end
end
