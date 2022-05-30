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
        email_template: params[:template]
      )
    end

  private

    def selected_template_preview
      notify_client.generate_template_preview(
        params[:template],
        personalisation: personalisation,
      )
    end

    # return [Hash]
    def personalisation
      contact = CaseContactPresenter.new(@current_case)

      { first_name: contact.first_name, last_name: contact.last_name, from_name: current_agent.full_name, reference: @current_case.ref }
    end

    def preview_email_body
      helpers.markdown_to_html(selected_template_preview.body)
    end

    def notify_client
      Notifications::Client.new(ENV["NOTIFY_API_KEY"])
    end
  end
end
