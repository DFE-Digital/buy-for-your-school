module FrameworkRequests
  class EnergyRequestAboutForm < BaseForm
    validates :energy_request_about, presence: true

    attr_writer :energy_request_about

    def initialize(attributes = {})
      super
      @energy_request_about ||= framework_request.energy_request_about
    end

    def data
      return super if energy_request_about == :energy_contract

      super.merge(have_energy_bill: nil, energy_alternative: nil)
    end

    def energy_request_about
      @energy_request_about&.to_sym
    end

    def energy_request_about_options
      FrameworkRequest.energy_request_abouts.keys
    end
  end
end
