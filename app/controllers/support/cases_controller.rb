module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show edit update]

    def index
      @cases = Case.all.map { |c| CasePresenter.new(c) }
    end

    def show; end

    def edit
      @agents = Agent.all.map { |a| AgentPresenter.new(a) }
    end

    def update
      # TODO: remove :nocov: and start testing
      # :nocov:
      @current_case.agent = Agent.find_by(id: params.dig(:support_case, :agent))
      @current_case.state = "open"
      @current_case.save!
      # :nocov:

      redirect_to support_cases_path
    end

  private

    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end
  end
end
