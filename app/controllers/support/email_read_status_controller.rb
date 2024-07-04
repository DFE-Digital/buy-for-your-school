module Support
  class EmailReadStatusController < ApplicationController
    before_action :find_email

    def update
      @email.update!(is_read: new_status)
      @email.ticket.update!(action_required: @email.ticket.emails.unread.inbox.any?) if @email.ticket.present?

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
  end
end
