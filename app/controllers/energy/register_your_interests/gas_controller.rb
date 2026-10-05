module Energy
  module RegisterYourInterests
    class GasController < BaseController
      before_action { @registration.step = "gas" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_mat_path) }

      def index; end

      def create
        attributes = registration_params(:switch_gas, :gas_contract_end_date)
        attributes[:gas_contract_end_date] = nil if attributes[:switch_gas] == "false"
        save_step("gas", attributes, energy_register_your_interest_electricity_path)
      end
    end
  end
end
