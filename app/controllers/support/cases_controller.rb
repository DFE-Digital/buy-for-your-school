module Support
  class CasesController < Cases::ApplicationController
    before_action :current_case, only: %i[show]

    def index
      @cases = Case.includes(%i[agent category organisation]).all.map { |c| CasePresenter.new(c) }
      @new_cases = Case.includes(%i[agent category organisation]).initial.map { |c| CasePresenter.new(c) }
      @my_cases = Case.includes(%i[agent category organisation]).by_agent(current_agent&.id).map { |c| CasePresenter.new(c) }
    end

    def show
      @back_url = support_cases_path
    end

  private

    # @return [CasePresenter, nil]
    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end
  end
end
