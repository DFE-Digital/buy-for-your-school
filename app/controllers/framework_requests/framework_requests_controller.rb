class FrameworkRequests::FrameworkRequestsController < FrameworkRequests::ApplicationController
  skip_before_action :authenticate_user!

  before_action :framework_request, only: %i[show]

  def index
    session[:faf_referrer] = referral_link
    session.delete(:energy_case_tasks_path)
    session.delete(:energy_onboarding)
  end

  def show
    if framework_request.submitted?
      flash.clear
      return redirect_to framework_request_submission_path(framework_request)
    end

    @current_user = UserPresenter.new(current_user)
    @framework_request.valid?(:complete)
    @error_summary_presenter = FrameworkRequests::ErrorSummaryPresenter.new(@framework_request.errors.messages, @framework_request.id, current_user)
  end

private

  def referral_link
    params[:referred_by] ? Base64.decode64(params[:referred_by]) : request.referer || "direct"
  end

  def framework_request
    @framework_request ||= FrameworkRequestPresenter.new(FrameworkRequest.find(params[:id]))
  end
end
