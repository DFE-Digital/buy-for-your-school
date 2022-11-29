module FrameworkRequests
  class EnergyAlternativeForm < BaseForm
    validates :energy_alternative, presence: true

    attr_writer :energy_alternative

    def energy_alternative
      @energy_alternative&.to_sym
    end

    def energy_alternative_options
      %i[different_format email_later no_bill no_thanks]
    end
  end
end
