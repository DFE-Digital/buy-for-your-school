module Support
  class Cases::Emails::ContentController < Cases::ApplicationController
    before_action :set_template

    def edit
      @back_url = new_support_case_email_type_path(@current_case)
      @case_email_content_form = CaseEmailContentForm.new(email_body: basic_email_body)
    end

    def show
      @current_case = CasePresenter.new(@current_case)

      if @template == :basic
        @back_url = new_support_case_email_type_path(@current_case)

        @case_email_content_form = CaseEmailContentForm.new(
          email_body: basic_email_body,
          email_subject: basic_email_subject,
          email_template: params[:template],
        )
      else
        @back_url = support_case_email_templates_path(@current_case)

        @case_email_content_form = CaseEmailContentForm.new(
          email_body: selected_template_preview.body,
          email_subject: selected_template_preview.subject,
          email_template: params[:template],
        )
      end
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

    def selected_template_preview
      Notifications::Client.new(ENV["NOTIFY_API_KEY"])
        .generate_template_preview(params[:template], personalisation: {
          toName: @current_case.full_name,
          fromName: current_agent.full_name,
        })
    end

    def templated_email_body
      selected_template_preview.body
    end

    def basic_email_subject
      I18n.t("support.case_email_content.preview.subject.default_value")
    end

    def basic_email_body
      I18n.t("support.case_email_content.edit.default_email_body.non_template")
    end

    def validation
      CaseEmailContentFormSchema.new.call(**case_email_content_form_params)
    end

    # set default elsewhere?
    #
    def case_email_content_form_params
      defaults = { email_subject: basic_email_subject }

      params.require(:case_email_content_form)
        .permit(:email_body, :email_subject, :email_template)
        .reverse_merge(defaults)
    end

    def set_template
      @template = params.fetch(:template, :basic).to_sym
    end
  end
end
