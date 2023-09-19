module FrameworkRequests
  class ContractStartDateForm < BaseForm
    validates :contract_start_date_known, presence: true
    validates :contract_start_date, presence: true, if: -> { contract_start_date_known == "true" }
    validate :contract_start_date_valid, if: -> { contract_start_date_known == "true" }

    attr_accessor :contract_start_date_known, :contract_start_date

    def initialize(attributes = {})
      super
      @contract_start_date_known ||= framework_request.contract_start_date_known
      @contract_start_date = framework_request.contract_start_date if @contract_start_date.blank?
    end

  private

    def contract_start_date_valid
      return if contract_start_date.is_a?(Date)

      begin
        self.contract_start_date = Date.civil(contract_start_date["year"].to_i, contract_start_date["month"].to_i, contract_start_date["day"].to_i)
      rescue Date::Error, TypeError
        errors.add(:contract_start_date, I18n.t("faf.contract_start_date.date.invalid"))
      end
    end
  end
end
