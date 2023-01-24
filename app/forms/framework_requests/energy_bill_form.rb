module FrameworkRequests
  class EnergyBillForm < BaseForm
    validates :have_energy_bill, presence: true

    attr_accessor :have_energy_bill

    def initialize(attributes = {})
      super
      @have_energy_bill = framework_request.have_energy_bill if @have_energy_bill.nil?
    end

    def data
      return super unless have_energy_bill?

      super.merge(energy_alternative: nil)
    end

    def have_energy_bill?
      ActiveModel::Type::Boolean.new.cast(@have_energy_bill)
    end
  end
end
