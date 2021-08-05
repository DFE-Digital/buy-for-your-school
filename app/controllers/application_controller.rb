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
  def current_user
    @current_user ||= FindOrCreateUserFromSession.new(session_hash: session.to_hash).call
  end

  def authenticate_user!
    return if current_user

    session.delete(:dfe_sign_in_uid)
    redirect_to root_path, notice: "You've been signed out."
  end

  def current_journey
    journey_id = params[:journey_id].presence || params[:id]
    @current_journey ||= Journey.find(journey_id)
  end

  def check_user_belongs_to_journey?
    return true if current_journey.user == current_user

    render "errors/not_found", status: :not_found
  end
end
