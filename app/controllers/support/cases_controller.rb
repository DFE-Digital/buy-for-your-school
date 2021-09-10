module Support
  class CasesController < ApplicationController
    def index
      @cases = Support::Case.all.map { |c| CasePresenter.new(c) }
    end

    def show
      @case = CasePresenter.new(case_by_id)
    end

    def edit
      case_by_id
      @agents = Support::Agent.all.map { |a| AgentPresenter.new(a) }
    end

    def update
      # TODO: Actually assign worker to a case
      case_by_id.update!(state: "open")

      redirect_to support_cases_path
    end

  private

    def case_by_id
      @case = Support::Case.find_by(id: params[:id])
    end
  end
end
