module Cms
  class SigninController < ApplicationController
    skip_before_action :authenticate_user!
    def show
      session.delete(:email_evaluator_link)
      session.delete(:email_school_buyer_link)
      session.delete(:energy_case_tasks_path)
      session.delete(:energy_onboarding)
      session.delete(:faf_referrer)
      @start_now_button_route = current_user.guest? ? "/auth/dfe" : cms_entrypoint_path
      @start_now_button_method = current_user.guest? ? :post : :get
    end
  end
end
