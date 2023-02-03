class FrameworkRequest < Request
  belongs_to :user, optional: true

  has_many :energy_bills, class_name: "EnergyBill"

  enum energy_request_about: { energy_contract: 1, not_energy_contract: 0 }, _suffix: true
  enum energy_alternative: { different_format: 0, email_later: 1, no_bill: 2, no_thanks: 3 }, _suffix: true

  def allow_bill_upload?
    Flipper.enabled?(:energy_bill_flow) && is_energy_request && energy_request_about == "energy_contract" &&
      (have_energy_bill || energy_alternative == "different_format")
  end

  def has_bills?
    energy_bills.any?
  end
end
