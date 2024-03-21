class RequestPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

  # return [String]
  def procurement_amount
    return I18n.t("generic.not_provided") if super.nil?

    number_to_currency(super, unit: "£", precision: 2)
  end

  # return [String]
  def special_requirements
    return "No" if super.blank?

    super
  end
end
