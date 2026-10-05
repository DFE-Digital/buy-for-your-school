module Energy
  module RegisterYourInterests
    class PhoneNumbersController < BaseController
      before_action { @registration.step = "phone" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_email_path) }

      def index; end

      def create
        save_step("phone", registration_params(:phone_number), energy_register_your_interest_mat_path)
      end
    end
  end
end
