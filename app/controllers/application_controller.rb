# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :authenticate_user!, except: :health_check

  protect_from_forgery

  def health_check
    render json: {rails: "OK"}, status: :ok
  end

  protected

  helper_method :current_user
  def current_user
    @current_user ||= begin
      user = FindOrCreateUserFromSession.new(session_hash: session.to_hash).call
      return user if user.present?

      false
    end
  end

  def authenticate_user!
    return if current_user

    session.delete(:dfe_sign_in_uid)
    redirect_to new_dfe_path
  end
end
