module FrameworkRequests
  class EnergyRequestForm < BaseForm
    validates :is_energy_request, presence: true

    attr_accessor :is_energy_request

    def is_energy_request?
      ActiveModel::Type::Boolean.new.cast(@is_energy_request)
    end
  end
end
