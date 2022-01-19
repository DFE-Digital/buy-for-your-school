module Support
  class EmailReadStatusController < ApplicationController
    before_action :find_email

    def update
      @email.update!(is_read: new_status)
      redirect_back fallback_location: support_email_path(@email)
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
