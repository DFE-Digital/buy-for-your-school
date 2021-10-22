module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show]

    def index
      @cases = Case.includes(%i[agent interactions]).all.map { |c| CasePresenter.new(c) }
    end

    def show
      @back_url = support_cases_path
    end

  private

    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end
  end
end
