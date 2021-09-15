module Support
  class CasesController < ApplicationController
    before_action :find_case_by_id, only: %i[show edit update]

    def index
      @cases = Case.all.map { |c| CasePresenter.new(c) }
    end

    def show; end

    def edit
      @agents = Agent.all.map { |a| AgentPresenter.new(a) }
    end

    def update
      # TODO: Actually assign worker to a case
      @case.update!(state: "open")

      redirect_to support_cases_path
    end

  private

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def find_case_by_id
      @case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
