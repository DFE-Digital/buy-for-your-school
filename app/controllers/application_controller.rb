# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :authenticate_user!, except: :health_check

  protect_from_forgery

  def health_check
    render json: { rails: "OK" }, status: :ok
  end

protected

  helper_method :current_user

  # @return [UserPresenter]
  #
  def current_user
    @current_user ||= UserPresenter.new(get_current_user)
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

  # @return [JourneyPresenter]
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
    return true if current_journey.user == get_current_user

    render "errors/not_found", status: :not_found
  end

private

  # @return [User, Guest]
  #
  def get_current_user
    CurrentUser.new.call(uid: session[:dfe_sign_in_uid])
  end
end
