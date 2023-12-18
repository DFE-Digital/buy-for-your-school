class CaseRequest::ContractStartDater
  include ActiveModel::Model

  validates :contract_start_date_known, presence: true
  validates :contract_start_date, presence: true, if: -> { contract_start_date_known == "true" }
  validate :contract_start_date_valid, if: -> { contract_start_date_known == "true" }

  attr_accessor(
    :case_request,
    :contract_start_date_known,
    :contract_start_date,
  )

  def save!
    case_request.choose_contract_start_date(contract_start_date, contract_start_date_known)
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
