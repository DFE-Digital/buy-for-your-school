module Support
  class Cases::EvaluationDueDatesController < Cases::ApplicationController
    before_action :set_current_case
    before_action { @back_url = "/support/cases/#{params[:case_id]}#tasklist" }
    def edit
      @evaluation_due_date = @current_case
    end

    def update
      @evaluation_due_date = Support::Case.find(params[:case_id])
      @evaluation_due_date.assign_attributes(evaluation_due_date_params)

      if @evaluation_due_date.valid?(:update_due_date_form)
        if @evaluation_due_date.save(context: :update_due_date_form)
          redirect_to @back_url
        else
          render :edit
        end
      else
        render :edit
      end
    end

  private

    def set_current_case
      @current_case = Support::Case.find(params[:case_id])
    end

    def evaluation_due_date_params
      form_params = params.require(:support_case).permit
      form_params[:evaluation_due_date] = date_param(:support_case, :evaluation_due_date)
      form_params
    end

    def date_param(form_param, date_field)
      date = params.fetch(form_param, {}).permit("#{date_field}(1i)", "#{date_field}(2i)", "#{date_field}(3i)")
      begin
        Date.new(date["#{date_field}(1i)"].to_i, date["#{date_field}(2i)"].to_i, date["#{date_field}(3i)"].to_i)
      rescue StandardError
        nil
      end
    end
  end
end
