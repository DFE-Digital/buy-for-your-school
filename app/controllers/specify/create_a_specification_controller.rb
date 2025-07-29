class Specify::CreateASpecificationController < Specify::ApplicationController
  skip_before_action :authenticate_user!

  def show
    session.delete(:email_evaluator_link)
    session.delete(:email_school_buyer_link)
    @start_now_button_route = current_user.guest? ? "/auth/dfe" : dashboard_path
    @start_now_button_method = current_user.guest? ? :post : :get
  end
end
