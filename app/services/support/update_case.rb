module Support
  #
  # Service to update an existing Case
  #
  class UpdateCase
    # @param current_case [Support::Case] existing case to be updated
    attr_reader :current_case, :current_user, :params

    def initialize(current_case, current_user, params)
      @current_case = current_case
      @current_user = current_user
      @params = params
    end

    # @return [Support::Case]
    def call
      if assigning_to_agent?
        current_case.agent = agent
        current_case.state = "open"
        current_case.save!

        create_interaction("Case assigned: New assignee is #{agent.first_name}")
      end

      if resolving?
        current_case.agent = nil
        current_case.state = "resolved"
        current_case.save!

        create_interaction("Case resolved: #{params[:resolve_message]}")
      end

      current_case
    end

  private

    def resolving?
      params[:resolve_message].present? && !current_case.resolved?
    end

    def assigning_to_agent?
      params[:agent].present?
    end

    def agent
      @agent ||= Agent.find_by(id: params[:agent])
    end

    def create_interaction(text)
      Interaction.create!(
        body: text,
        event_type: "note",
        case_id: current_case.id,
        agent_id: current_user.id,
      )
    end
  end
end
