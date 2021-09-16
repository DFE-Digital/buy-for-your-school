module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show edit update]
    before_action :agent, only: %i[update]

    def index
      @cases = Case.all.map { |c| CasePresenter.new(c) }
    end

    def show; end

    def edit
      @agents = Agent.all.map { |a| AgentPresenter.new(a) }
    end

    def update
      UpdateCase.new(current_case, agent).call

      redirect_to support_cases_path
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
