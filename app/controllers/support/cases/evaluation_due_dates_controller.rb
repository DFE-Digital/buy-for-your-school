module Support
  class Cases::EvaluationDueDatesController < Cases::ApplicationController
    before_action :set_current_case
    before_action { @back_url = support_case_path(@current_case, anchor: "tasklist") }

    include HasDateParams
    def edit
      @case_evaluation_due_date_form = CaseEvaluationDueDateForm.new(**current_case.to_h)
    end

    def update
      @case_evaluation_due_date_form = CaseEvaluationDueDateForm.from_validation(validation)

      if validation.success?
        @current_case.update!(@case_evaluation_due_date_form.to_h)
        log_evaluation_due_date_updated
        redirect_to @back_url
      else
        render :edit
      end
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def validation
      @validation ||= CaseEvaluationDueDateFormSchema.new.call(**evaluation_due_date_params)
    end

    def evaluation_due_date_params
      form_params = params.require(:case_evaluation_due_date_form).permit
      form_params[:evaluation_due_date] = date_param(:case_evaluation_due_date_form, :evaluation_due_date)
      form_params
    end

    def log_evaluation_due_date_updated
      return unless @current_case.saved_change_to_evaluation_due_date?

      if @current_case.saved_changes["evaluation_due_date"].first.present?
        event_type = :evaluation_due_date_updated
        old_date = @current_case.saved_changes["evaluation_due_date"].first
        new_date = @current_case.saved_changes["evaluation_due_date"].last
        body = "Due date changed from #{old_date} to #{new_date} by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = { from: old_date, to: new_date }
      else
        event_type = :evaluation_due_date_added
        body = "Due date set to #{@current_case.evaluation_due_date} by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = { due_date: @current_case.evaluation_due_date }
      end

      Support::EvaluationJourneyTracking.new(event_type, params[:case_id], body, additional_data).call
    end
  end
end
