# Helpers for a support request to display information on the page
class SupportRequestPresenter < SimpleDelegator
  include ActionView::Helpers::NumberHelper

  # @return [String] email address of user requesting support
  def email
    user&.email
  end

  # The name of the school that matches the chosen school URN
  #
  # @return [String] the name of the school
  def school_name
    user.supported_schools.find { |school| school.urn == school_urn }&.name
  end

  # return [JourneyPresenter, nil]
  def journey
    JourneyPresenter.new(super) if super.present?
  end

  # return [String]
  def procurement_amount
    return "-" unless super

    number_to_currency(super, unit: "£", precision: 2)
  end

  # return [String, nil]
  def confidence_level
    return if super.blank?

    I18n.t("request.confidence_level.levels.#{super}")
  end

  # return [String]
  def special_requirements
    super || "-"
  end

private

  def user
    UserPresenter.new(super)
  end
end
