module FrameworkRequests
  class ProcurementAmountForm < BaseForm
    validate :procurement_amount_validation

    attr_accessor :procurement_amount

    def initialize(attributes = {})
      super
      @procurement_amount ||= (sprintf("%.2f", framework_request.procurement_amount) if framework_request.procurement_amount.present?)
    end

    def procurement_amount_validation
      errors.add(:procurement_amount, I18n.t("framework_request.errors.rules.procurement_amount.invalid")) if invalid_number?
      errors.add(:procurement_amount, I18n.t("framework_request.errors.rules.procurement_amount.too_large")) if too_large?
    end

  private

    def invalid_number?
      return false if @procurement_amount.blank?

      false if Float(@procurement_amount)
    rescue ArgumentError
      true
    end

    def too_large?
      return false if @procurement_amount.blank?

      Float(@procurement_amount) >= 10**7
    rescue ArgumentError
      false
    end
  end
end
