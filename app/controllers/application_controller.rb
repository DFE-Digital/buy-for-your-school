# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :authenticate_user!, except: :health_check

  protect_from_forgery

  def health_check
    render json: { rails: "OK" }, status: :ok
  end

protected

  helper_method :current_user, :support?, :cookie_policy

  # @return [User, Guest]
  #
  def current_user
    @current_user ||= CurrentUser.new.call(uid: session[:dfe_sign_in_uid])
  end

  # before_action - Ensure session is ended
  #
  # @return [nil]
  #
  def authenticate_user!
    return unless current_user.guest?

    session.delete(:dfe_sign_in_uid)
    redirect_to root_path, notice: I18n.t("banner.session.visitor")
  end

  # @return [Journey]
  #
  def current_journey
    journey_id = params[:journey_id].presence || params[:id]
    @current_journey ||= JourneyPresenter.new(Journey.find(journey_id))
  end

  # `Before Action` on:
  #   - steps_controller
  #   - answers_contorller
  #   - journeys_controller
  #   - specifications_controller
  #
  def check_user_belongs_to_journey?
    return true if current_journey.user == current_user

    render "errors/not_found", status: :not_found
  end

  # Is the user currently on the support side?
  def support?
    false
  end

  def cookie_policy
    CookiePolicy.new(cookies)
  end

  def current_url_b64
    Base64.encode64(request.fullpath)
  end
end
