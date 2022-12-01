module FrameworkRequests
  class EnergyRequestForm < BaseForm
    validates :is_energy_request, presence: true

    attr_accessor :is_energy_request

    def initialize(attributes = {})
      super
      @is_energy_request = framework_request.is_energy_request if @is_energy_request.nil?
    end

    def data
      return super if is_energy_request?

      super.merge(energy_request_about: nil, have_energy_bill: nil, energy_alternative: nil)
    end

    def is_energy_request?
      ActiveModel::Type::Boolean.new.cast(@is_energy_request)
    end
  end
end
