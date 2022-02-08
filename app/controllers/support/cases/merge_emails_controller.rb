module Support
  class Cases::MergeEmailsController < Cases::ApplicationController
    def new
      @merge_emails_form = CaseMergeEmailsForm.new
    end

    def preview
      if validation.success?
        @from_case = CasePresenter.new(current_case)
        @to_case = CasePresenter.new(Case.find_by(ref: merge_emails_params[:merge_into_case_id]))
        render :preview
      else
        @merge_emails_form = CaseMergeEmailsForm.from_validation(validation)
        render :new
      end
    end

    def create
      MergeCaseEmails.new(params[:from_case_id], params[:to_case_id]).call
      render :show
    end

  private

    def validation
      CaseMergeEmailsFormSchema.new.call(**merge_emails_params)
    end

    def merge_emails_params
      params.require(:merge_emails_form).permit(:merge_into_case_id)
    end
  end
end
