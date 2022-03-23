module Support
  class Cases::Emails::TypesController < Cases::ApplicationController
    before_action :set_back_url

    def new
      @case_email_type_form = CaseEmailTypeForm.new
    end

    def create
      @case_email_type_form = CaseEmailTypeForm.from_validation(validation)

      if validation.success?
        continue_on_to_next_email_stage(@case_email_type_form.choice)
      else
        render :new
      end
    end

  private

    def continue_on_to_next_email_stage(choice)
      if choice == "template"
        redirect_to support_case_email_templates_path(@current_case)
      else
        redirect_to edit_support_case_email_content_path(@current_case, template: EmailTemplates::IDS[:basic_template])
      end
    end

    def validation
      CaseEmailTypeFormSchema.new.call(**case_email_type_form_params)
    end

    def case_email_type_form_params
      params.require(:case_email_type_form).permit(:choice)
    end

    def set_back_url
      @back_url = support_case_path(@current_case)
    end
  end
end
