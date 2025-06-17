module Energy
  module SwitchingEnergyTypeHelper
    def switching_gas?
      @onboarding_case_organisation.switching_energy_type_gas?
    end

    def switching_electricity?
      @onboarding_case_organisation.switching_energy_type_electricity?
    end

    def switching_both?
      @onboarding_case_organisation.switching_energy_type_gas_electricity?
    end
  end
end
