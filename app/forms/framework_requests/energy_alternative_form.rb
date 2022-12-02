module FrameworkRequests
  class EnergyAlternativeForm < BaseForm
    validates :energy_alternative, presence: true

    attr_writer :energy_alternative

    def initialize(attributes = {})
      super
      @energy_alternative ||= framework_request.energy_alternative
    end

    def energy_alternative
      @energy_alternative&.to_sym
    end

    def energy_alternative_options
      FrameworkRequest.energy_alternatives.keys
    end
  end
end
