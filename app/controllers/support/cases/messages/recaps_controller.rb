module Support
  class Cases::Messages::RecapsController < Cases::ApplicationController
    before_action :current_email

    def show
      @message = Support::Messages::OutlookMessagePresenter.new(current_email)
      @expand_recap = params[:expand] == "true"
    end

  private

    def current_email
      @current_email = Support::Email.find(params[:message_id]) if params[:message_id].present?
    end
  end
end
