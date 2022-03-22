module Support
  class Cases::Emails::ContentController < Cases::ApplicationController
    include MarkdownHelper

    # Edit non-templated content
    def edit
      @back_url = new_support_case_email_type_path(@current_case)
      @case_email_content_form = CaseEmailContentForm.new(text: basic_email_text_variable, email_template: params[:template])
    end

    # Preview of email with send button
    def show
      @current_case = CasePresenter.new(@current_case)

      @back_url = if basic_template?
                    new_support_case_email_type_path(@current_case)
                  else
                    support_case_email_templates_path(@current_case)
                  end

      @case_email_content_form = CaseEmailContentForm.new(
        email_body: preview_email_body,
        email_subject: selected_template_preview.subject,
        email_template: params[:template],
        text: basic_email_text_variable,
      )
    end

    # Handle non-template text entry
    def update
      if validation.success?
        @case_email_content_form = CaseEmailContentForm.new(
          email_body: preview_email_body,
          email_subject: selected_template_preview.subject,
          email_template: params[:template],
          text: basic_email_text_variable,
        )
        @back_url = edit_support_case_email_content_path(@current_case, case_email_content_form: { text: basic_email_text_variable })

        # Preview of email with send button
        render :show
      else
        @case_email_content_form = CaseEmailContentForm.from_validation(validation)
        @back_url = new_support_case_email_type_path(@current_case)

        # Edit non-templated content
        render :edit
      end
    end

  private

    def selected_template_preview
      notify_client.generate_template_preview(
        params[:template],
        personalisation: personalisation,
      )
    end

    # return [Boolean] Verifies if the  tempalte being used is templated or non-templated.
    # If the basic template changes id on notify, this needs to be changed and the #continue_onto_next_email_stage
    # action on the Support::Cases::Emails::TypesController will also need to be changed

    def basic_template?
      EmailTemplates.basic_template?(params[:template])
    end

    # return [Hash]
    def personalisation
      contact = CaseContactPresenter.new(@current_case)

      personalisation_params = { first_name: contact.first_name, last_name: contact.last_name, from_name: current_agent.full_name, reference: @current_case.ref }

      personalisation_params[:text] = basic_email_text_variable if basic_template?

      personalisation_params
    end

    def preview_email_body
      if basic_template?
        helpers.simple_format(selected_template_preview.body.gsub(basic_email_text_variable, helpers.markdown_to_html(basic_email_text_variable)))
      else
        helpers.markdown_to_html(selected_template_preview.body)
      end
    end

    def basic_email_subject
      I18n.t("support.case_email_content.preview.subject.default_value")
    end

    def basic_email_text_variable
      return case_email_content_form_params[:text] if params[:case_email_content_form].present?

      I18n.t("support.case_email_content.edit.default_email_body.non_template")
    end

    def validation
      CaseEmailContentFormSchema.new.call(**case_email_content_form_params)
    end

    def case_email_content_form_params
      defaults = { email_subject: basic_email_subject }

      params.require(:case_email_content_form)
        .permit(:email_body, :email_subject, :email_template, :text)
        .reverse_merge(defaults)
    end

    def notify_client
      Notifications::Client.new(ENV["NOTIFY_API_KEY"])
    end
  end
end
