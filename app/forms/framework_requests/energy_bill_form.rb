module FrameworkRequests
  class EnergyBillForm < BaseForm
    validates :have_energy_bill, presence: true

    attr_accessor :have_energy_bill

    def have_energy_bill?
      ActiveModel::Type::Boolean.new.cast(@have_energy_bill)
    end
  end
end
