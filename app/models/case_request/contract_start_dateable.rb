module CaseRequest::ContractStartDateable
  extend ActiveSupport::Concern

  def contract_start_dater(params = {})
    CaseRequest::ContractStartDater.new(case_request: self, **params)
  end

  def choose_contract_start_date(contract_start_date, contract_start_date_known)
    self.contract_start_date = contract_start_date
    self.contract_start_date_known = contract_start_date_known
    save!
  end
end
