module Energy
  module RegisterYourInterests
    class ElectricitiesController < BaseController
      include HasDateParams

      before_action { @registration.step = "electricity" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_gas_path) }

      def index
        @form = Energy::RegisterYourInterestElectricityForm.new(
          switch_electricity: @registration.switch_electricity,
          electricity_contract_end_date: @registration.electricity_contract_end_date,
        )
      end

      def create
        @form = Energy::RegisterYourInterestElectricityForm.new(
          switch_electricity: registration_params(:switch_electricity)[:switch_electricity],
          electricity_contract_end_date: nil,
        )
        preserve_date_param(@form, :energy_register_your_interest, :electricity_contract_end_date)

        if @form.valid?
          save_step("electricity", @form.registration_attributes, energy_register_your_interest_check_your_answers_path)
        else
          render :index, status: :unprocessable_entity
        end
      end
    end
  end
end
