module Support
  class Cases::MergeEmailsController < Cases::ApplicationController
    def new
      @merge_emails_form = CaseMergeEmailsForm.new
    end

    def create
      @merge_emails_form = CaseMergeEmailsForm.from_validation(validation)

      if validation.success? && @merge_emails_form.merge_emails(current_case)
        @merge_emails_form
        redirect_to support_case_path(current_case, anchor: "school-details"),
                    notice: I18n.t("support.case_contact_details.flash.updated")
      else
        render :edit
      end
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
