module Energy
  module RegisterYourInterests
    class GasController < BaseController
      include HasDateParams

      before_action { @registration.step = "gas" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_mat_path) }

      def index
        @form = Energy::RegisterYourInterestGasForm.new(
          switch_gas: @registration.switch_gas,
          gas_contract_end_date: @registration.gas_contract_end_date,
        )
      end

      def create
        @form = Energy::RegisterYourInterestGasForm.new(
          switch_gas: registration_params(:switch_gas)[:switch_gas],
          gas_contract_end_date: nil,
        )
        preserve_date_param(@form, :energy_register_your_interest, :gas_contract_end_date)

        if @form.valid?
          save_step("gas", @form.registration_attributes, energy_register_your_interest_electricity_path)
        else
          render :index, status: :unprocessable_entity
        end
      end
    end
  end
end
