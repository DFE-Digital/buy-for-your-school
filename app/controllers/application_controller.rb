# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include Pundit::Authorization
  include InsightsTrackable
  include ExceptionDataPrepareable

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :authenticate_user!, except: %i[health_check maintenance]
  before_action :set_current_request_id

  protect_from_forgery

  add_flash_types :success

  def health_check
    render json: { rails: "OK" }, status: :ok
  end

  def maintenance
    redirect_to root_path unless Flipper.enabled?(:maintenance_mode)
  end

protected

  helper_method :current_user, :cookie_policy, :internal_portal?, :google_analytics_id, :hosted_development?, :hosted_production?, :hosted_staging?, :record_ga?, :engagement_portal?, :support_portal?, :frameworks_portal?, :cec_portal?, :current_url_b64, :header_link

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
  #   - answers_controller
  #   - journeys_controller
  #   - specifications_controller
  #
  def check_user_belongs_to_journey?
    return true if current_journey.user == current_user

    render "errors/not_found", status: :not_found
  end

  def support_portal?
    portal_namespace.to_s.inquiry.support?
  end

  def engagement_portal?
    portal_namespace.to_s.inquiry.engagement?
  end

  def frameworks_portal?
    portal_namespace.to_s.inquiry.frameworks?
  end

  def procurement_support_portal?
    portal_namespace.to_s.inquiry.procurement_support?
  end

  def cec_portal?
    portal_namespace.to_s.inquiry.cec?
  end

  def portal_namespace
    :none
  end

  def google_analytics_id
    if hosted_development?
      "G-JHQ4K916N1"
    elsif hosted_staging?
      "G-8770N0RLNE"
    elsif hosted_production?
      "G-PT4157VC9D"
    end
  end

  def internal_portal?
    support_portal? || engagement_portal? || frameworks_portal? || cec_portal?
  end

  def hosted_development?
    request.url.starts_with?("https://dev.")
  end

  def hosted_production?
    request.url.starts_with?("https://www.")
  end

  def hosted_staging?
    request.url.starts_with?("https://staging.")
  end

  def redirect_to_portal
    redirect_to "/cms"
  end

  def record_ga?
    google_analytics_id.present? && (internal_portal? || cookie_policy.accepted?)
  end

  def cookie_policy
    CookiePolicy.new(cookies)
  end

  def header_link
    return framework_requests_path if procurement_support_portal?

    root_path
  end

  def current_url_b64(tab = nil)
    Base64.encode64("#{request.fullpath}#{"##{tab.to_s.dasherize}" if tab.present?}")
  end

  def back_link_param(back_to = params[:back_to])
    return if back_to.blank?

    Base64.decode64(back_to)
  end

  def tracking_base_properties = { user_id: current_user.id }

  def set_current_request_id = Current.request_id = request.request_id
end
