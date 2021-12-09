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

    def update
      current_case.update!(procurement: Support::Procurement.new) unless current_case.procurement
      current_case.update!(existing_contract: Support::ExistingContract.new) unless current_case.existing_contract
      current_case.update!(new_contract: Support::NewContract.new) unless current_case.new_contract

      respond_to do |format|
        format.js
      end
    end

  private

    # @return [CasePresenter, nil]
    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end
  end
end
