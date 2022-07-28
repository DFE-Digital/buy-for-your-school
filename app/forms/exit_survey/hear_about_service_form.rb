# Collect hear about service
#
class ExitSurvey::HearAboutServiceForm < ExitSurvey::Form
  # @!attribute [r] hear about service
  # @return [Symbol]
  option :hear_about_service, Types::Params::Symbol, optional: true

  # @!attribute [r] hear about service other
  # @return [String]
  option :hear_about_service_other, optional: true

  # @return [Array<String>] dfe_email, dfe_event, non_dfe_event, dfe_promotion, other_dfe_service_referral,
  #                         online_search, social_media, word_of_mouth, other
  def hear_about_service_options
    @hear_about_service_options ||= ExitSurveyResponse.hear_about_services.keys
  end

  # Set hear_about_service_other only if hear_about_service == :other so we don't end up with an empty string
  #
  # @return [Hash] form params as request attributes
  def data
    super.merge(hear_about_service_other: @hear_about_service == :other ? @hear_about_service_other : nil)
  end
end
