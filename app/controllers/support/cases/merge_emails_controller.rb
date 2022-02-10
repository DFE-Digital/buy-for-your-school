module Support
  class Cases::MergeEmailsController < Cases::ApplicationController
    def new
      @merge_emails_form = CaseMergeEmailsForm.new
    end

    def preview
      if validation.success?
        @from_case = CasePresenter.new(current_case)
        @to_case = CasePresenter.new(Case.find_by(ref: merge_emails_params[:merge_into_case_ref]))
        render :preview
      else
        @merge_emails_form = CaseMergeEmailsForm.from_validation(validation)
        render :new
      end
    end

    def create
      @to_case, @from_case = MergeCaseEmails.new(
        from_case: current_case,
        to_case: params[:merge_into_case_ref]
      ).call

      render :show
    rescue MergeCaseEmails::CaseNotNewError
      redirect_to support_case_path(@current_case), notice: I18n.t("support.case_merge_emails.flash.case_not_new")
    end

  private

    def validation
      CaseMergeEmailsFormSchema.new.call(**merge_emails_params, merge_from_case_ref: current_case.ref)
    end

    def merge_emails_params
      params.require(:merge_emails_form).permit(:merge_into_case_ref)
    end
  end
end
