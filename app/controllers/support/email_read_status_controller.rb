module Support
  class EmailReadStatusController < ApplicationController
    before_action :find_email

    def update
      @email.update!(is_read: new_status)
      update_action_required

      respond_to do |format|
        format.turbo_stream do
          @message = Support::Messages::OutlookMessagePresenter.new(@email)
          @current_case = @email.ticket
        end
        format.html { redirect_to support_case_message_thread_path(id: @email.outlook_conversation_id, case_id: @email.ticket_id) }
      end
    end

  private

    def find_email
      @email = ::Email.find(params[:email_id])
    end

    def new_status
      params[:status] == "read"
    end

    def update_action_required
      return if @email.ticket.blank?

      action_required = if Flipper.enabled?(:sc_tasklist_case)
                          notify_procops_action_required?
                        else
                          default_action_required?
                        end

      @email.ticket.update!(action_required:)
    end

    def notify_procops_action_required?
      unread_emails = @email.ticket.emails.unread.inbox.any?
      pending_evaluations = Support::Evaluator.where(support_case_id: @email.ticket_id, has_uploaded_documents: true, evaluation_approved: false).any?
      unread_emails || pending_evaluations
    end

    def default_action_required?
      @email.ticket.emails.unread.inbox.any?
    end

    helper_method def portal_email_read_status_path(message, additional_params = {})
      send("#{agent_portal_namespace}_email_read_status_path", message, additional_params)
    end

    def authorize_agent_scope = :access_individual_cases?
  end
end
