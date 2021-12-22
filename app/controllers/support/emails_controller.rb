module Support
  class EmailsController < ApplicationController
    def index
      @back_url = support_cases_path
      @new_emails = EmailPresenter.wrap_collection Support::Email.inbox.display_order.includes([:case])
      @my_case_emails = EmailPresenter.wrap_collection Support::Email.inbox.my_cases(current_agent).display_order.includes([:case])
    end

    def show
      @back_url = support_emails_path
      @email = EmailPresenter.new(Support::Email.find(params[:id]))
    end
  end
end
