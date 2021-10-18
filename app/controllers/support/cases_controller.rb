module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show edit update]
    before_action :agent, only: %i[update]

    def index
      @all_cases = Case.includes(%i[agent interactions]).all.map { |c| CasePresenter.new(c) }
      @new_cases = Case.includes(%i[agent interactions]).initial.map { |c| CasePresenter.new(c) }
      @my_cases = Case.includes(%i[agent interactions]).by_agent(current_agent&.id).map { |c| CasePresenter.new(c) }
    end

    def show
      @back_url = support_cases_path
    end

    def edit
      @agents = Agent.all.map { |a| AgentPresenter.new(a) }
      @back_url = support_cases_path(current_case)
    end

    def update
      UpdateCase.new(current_case, agent).call

      redirect_to support_case_path(anchor: "case-history")
    end

  private

    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end

    def agent
      @agent ||= Agent.find_by(id: params.dig(:support_case, :agent))
    end
  end
end
