module Support
  class Cases::Emails::ContentController < Cases::ApplicationController
    before_action :set_template

    def edit
      @back_url = new_support_case_email_type_path(@current_case)
      @case_email_content_form = CaseEmailContentForm.new(email_body: default_email_body)
    end

    def update
      @case_email_content_form = CaseEmailContentForm.from_validation(validation)

      if validation.success?
        @back_url = edit_support_case_email_content_path(@current_case)

        render :show
      else
        @back_url = new_support_case_email_type_path(@current_case)

        render :edit
      end
    end

  private

    def default_email_body
      I18n.t("support.case_email_content.edit.default_email_body.non_template")
    end

    def validation
      CaseEmailContentFormSchema.new.call(**case_email_content_form_params)
    end

    def case_email_content_form_params
      params.require(:case_email_content_form).permit(:email_body)
    end

    def set_template
      @template = params.fetch(:template, :basic).to_sym
    end
  end
end
