class FrameworkRequest < Request
  belongs_to :user, optional: true

  enum energy_request_about: { energy_contract: 0, general_question: 1, something_else: 2 }, _suffix: true
  enum energy_alternative: { different_format: 0, email_later: 1, no_bill: 2, no_thanks: 3 }, _suffix: true

  def allow_bill_upload?
    is_energy_request && energy_request_about == "energy_contract" &&
      (have_energy_bill || energy_alternative == "different_format")
  end

  def has_bills?; end
end
