require "securerandom"

module FeatureFlagTracking
  extend ActiveSupport::Concern

  # Keep this list limited to flags which represent experiments. Operational
  # flags can contain implementation details and should not be sent to
  # analytics as experiment cohorts.
  EXPERIMENT_FLAGS = %i[homepage_rfh_button].freeze
  ANONYMOUS_ACTOR_SESSION_KEY = :feature_flag_actor_id

  included do
    helper_method :ab_test_enabled?, :feature_flag_event_tags
  end

  def ab_test_enabled?(feature)
    Flipper.enabled?(feature, feature_flag_actor)
  end

  def feature_flag_event_tags
    EXPERIMENT_FLAGS.filter { |feature| ab_test_enabled?(feature) }.map(&:to_s)
  end

  # Replace DfE Analytics' default request event so page impressions carry the
  # same experiment cohort information as the custom events below.
  def trigger_request_event(event_type)
    return unless DfE::Analytics.enabled?
    return if path_excluded?

    request_id = RequestLocals.fetch(:dfe_analytics_request_id) { nil } # rubocop:disable Style/RedundantFetchBlock

    request_event = DfE::Analytics::Event.new
      .with_type(event_type)
      .with_request_details(request)
      .with_response_details(response)
      .with_request_uuid(request_id)

    with_feature_flag_context(request_event)

    DfE::Analytics::SendEvents.do([request_event.as_json])
  end

  def with_feature_flag_context(event)
    event.with_tags(feature_flag_event_tags)
    event.with_user(current_user) if respond_to?(:current_user, true)
    event.with_namespace(current_namespace) if respond_to?(:current_namespace, true)
    event
  end

private

  def feature_flag_actor
    if current_user.respond_to?(:guest?) && !current_user.guest?
      Flipper::Actor.new("user:#{current_user.dfe_sign_in_uid}")
    else
      Flipper::Actor.new("anonymous:#{session[ANONYMOUS_ACTOR_SESSION_KEY] ||= SecureRandom.uuid}")
    end
  end
end
