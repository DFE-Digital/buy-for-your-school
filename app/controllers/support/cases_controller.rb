module Support
  class CasesController < Cases::ApplicationController
    before_action :current_case, only: %i[show]

    include Concerns::HasInteraction

    def index
      @cases = Case.includes(%i[agent category organisation]).all.map { |c| CasePresenter.new(c) }.sort_by(&:last_updated_at)
      @new_cases = Case.includes(%i[agent category organisation]).initial.map { |c| CasePresenter.new(c) }.sort_by(&:last_updated_at)
      @my_cases = Case.includes(%i[agent category organisation]).by_agent(current_agent&.id).map { |c| CasePresenter.new(c) }.sort_by(&:last_updated_at)
    end

    def show
      @back_url = support_cases_path
    end

    def new
      @form = CreateCaseForm.new
      @back_url = support_cases_path
    end

    def create
      @form = CreateCaseForm.from_validation(validation)
      if validation.success? && params[:button] == "create"
        kase = CreateCase.new(@form.to_h).call
        create_interaction(kase.id, "hub_notes", form_params["hub_notes"]) if form_params["hub_notes"].present?
        create_interaction(kase.id, "hub_progress_notes", form_params["progress_notes"]) if form_params["progress_notes"].present?
        create_interaction(kase.id, "hub_migration", "Case Migration Data", @form.to_h)
        redirect_to support_case_path(kase)
      else
        render :new
      end
    end

  private

    # @return [CasePresenter, nil]
    def current_case
      @current_case ||= CasePresenter.new(Case.find_by(id: params[:id]))
    end

    def validation
      CreateCaseFormSchema.new.call(**form_params)
    end

    def form_params
      params.require(:create_case_form).permit(
        :school_urn,
        :organisation_id,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :category_id,
        :hub_case_ref,
        :estimated_procurement_completion_date,
        :estimated_savings,
        :hub_notes,
        :progress_notes,
        :request_type,
      )
    end
  end
end
