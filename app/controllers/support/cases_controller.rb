module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show edit update]

    def index
      @cases = Case.all.map { |c| CasePresenter.new(c) }
    end

    def show; end

    def edit
      if params[:option] == "assign"
        @agents = Agent.all.map { |a| AgentPresenter.new(a) }
      end

      render params.fetch(:option, "/errors/not_found")
    end

    def update
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

        create_interaction("Case resolved: #{update_params[:resolve_message]}")
      end

      redirect_to support_case_path(anchor: "case-history")
    end

  private

    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end

    def update_params
      @update_params ||= params.require(:support_case).permit(
        :agent,
        :resolve_message,
        :state,
      )
    end

    def resolving?
      update_params[:resolve_message].present? && !current_case.resolved?
    end

    def assigning_to_agent?
      update_params[:agent].present?
    end

    def agent
      @agent ||= Agent.find_by(id: update_params[:agent])
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
