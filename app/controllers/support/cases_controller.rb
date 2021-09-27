module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show edit update resolve]

    def index
      @cases = Case.all.map { |c| CasePresenter.new(c) }
    end

    def show; end

    def edit
      @agents = Agent.all.map { |a| AgentPresenter.new(a) }
    end

    def update
      UpdateCase.new(current_case, current_user, update_params).call

      redirect_to support_case_path(anchor: "case-history")
    end

    def resolve; end

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
  end
end
