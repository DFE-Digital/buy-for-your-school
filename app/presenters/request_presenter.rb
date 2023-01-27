class RequestPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

  # return [String]
  def procurement_amount
    return I18n.t("request.procurement_amount.not_known") if super.nil?

    number_to_currency(super, unit: "£", precision: 2)
  end

  # return [String]
  def special_requirements
    return "-" if super.blank?

    super
  end
end
