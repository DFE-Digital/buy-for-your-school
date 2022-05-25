class RequestPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

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
    return "-" if super.blank?

    super
  end
end
