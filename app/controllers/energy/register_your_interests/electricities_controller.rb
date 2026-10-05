module Energy
  module RegisterYourInterests
    class ElectricitiesController < BaseController
      before_action { @registration.step = "electricity" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_gas_path) }

      def index; end

      def create
        attributes = registration_params(:switch_electricity, :electricity_contract_end_date)
        attributes[:electricity_contract_end_date] = nil if attributes[:switch_electricity] == "false"
        save_step("electricity", attributes, energy_register_your_interest_check_your_answers_path)
      end
    end
  end
end
