module Support
  class EmailReadStatusController < ApplicationController
    before_action :find_email

    def update
      @email.update!(is_read: new_status)
      @email.case.update!(action_required: @email.case.emails.unread.inbox.any?) if @email.case.present?

      redirect_to support_case_message_thread_path(id: @email.outlook_conversation_id, case_id: @email.case_id)
    end

  private

    def find_email
      @email = Support::Email.find(params[:email_id])
    end

    def new_status
      params[:status] == "read"
    end
  end
end
