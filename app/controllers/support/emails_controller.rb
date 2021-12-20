module Support
  class EmailsController < ApplicationController
    def index
      @back_url = support_cases_path
      @new_emails = EmailPresenter.wrap_collection Support::Email.display_order.includes([:case])
    end
  end
end
