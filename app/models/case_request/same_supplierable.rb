module CaseRequest::SameSupplierable
  extend ActiveSupport::Concern

  def same_supplierer(same_supplier_used: self.same_supplier_used)
    CaseRequest::SameSupplierer.new(case_request: self, same_supplier_used:)
  end

  def choose_same_supplier(same_supplier_used)
    self.same_supplier_used = same_supplier_used
    save!
  end
end
