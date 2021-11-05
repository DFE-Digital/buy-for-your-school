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

    def new
      @case_hub_migration_form = CaseHubMigrationForm.new
      @back_url = support_cases_path
    end

    def create
      @case_hub_migration_form = CaseHubMigrationForm.from_validation(validation)

      if validation.success?
        redirect_to support_case_path(current_case), notice: I18n.t("support.case_hub_migration.flash.created")
      else
        render :new
      end
    end

  private

    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end

    def validation
      CaseHubMigrationFormSchema.new.call(**case_hub_migration_form_params)
    end

    def case_hub_migration_form_params
      params.require(:case_hub_migration_form).permit(:notes)
    end
  end
end
