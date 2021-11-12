module Support
  class CasesController < ApplicationController
    before_action :current_case, only: %i[show]

    def index
      @cases = Case.includes(%i[agent category]).all.map { |c| CasePresenter.new(c) }
      @new_cases = Case.includes(%i[agent category]).initial.map { |c| CasePresenter.new(c) }
      @my_cases = Case.includes(%i[agent category]).by_agent(current_agent&.id).map { |c| CasePresenter.new(c) }
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
