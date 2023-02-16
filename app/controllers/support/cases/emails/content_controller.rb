require "notify/email"

module Support
  class Cases::Emails::ContentController < Cases::ApplicationController
    include MarkdownHelper

    # Preview of email with send button
    def show
      @current_case = CasePresenter.new(@current_case)
      @back_url = support_case_email_templates_path(@current_case)

      @case_email_content_form = CaseEmailContentForm.new(
        email_body: preview_email_body,
        email_subject: selected_template_preview.subject,
        email_template: params[:template],
      )
    end

  private

    def selected_template_preview
      notify_client.generate_template_preview(
        params[:template],
        personalisation:,
      )
    end

    # return [Hash]
    def personalisation
      template = EmailTemplates::IDS.key(params[:template])
      details = { from_name: current_agent.full_name }

      if template == :exit_survey
        details.merge!(::Emails::ExitSurvey.new(recipient: @current_case, reference: @current_case.ref, school_name: @current_case.organisation.name).personalisation)
      else
        details.merge!(::Notify::Email.new(recipient: @current_case, reference: @current_case.ref, template: params[:template]).personalisation)
      end

      details
    end

    def preview_email_body
      helpers.markdown_to_html(selected_template_preview.body)
    end

    def notify_client
      ::Notifications::Client.new(ENV["NOTIFY_API_KEY"])
    end
  end
end
