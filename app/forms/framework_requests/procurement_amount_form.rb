module FrameworkRequests
  class ProcurementAmountForm < BaseForm
    include ActiveModel::Validations::Callbacks

    before_validation :format_amount
    validate :procurement_amount_validation

    attr_accessor :procurement_amount

    def initialize(attributes = {})
      super
      @procurement_amount ||= (sprintf("%.2f", framework_request.procurement_amount) if framework_request.procurement_amount.present?)
    end

    def format_amount
      @procurement_amount = @procurement_amount&.gsub(/[£,]/, "")
    end

    def procurement_amount_validation
      validator = Support::Forms::ValidateProcurementAmount.new(@procurement_amount)
      errors.add(:procurement_amount, I18n.t("framework_request.errors.rules.procurement_amount.invalid")) if validator.invalid_number?
      errors.add(:procurement_amount, I18n.t("framework_request.errors.rules.procurement_amount.too_large")) if validator.too_large?
    end
  end
end
