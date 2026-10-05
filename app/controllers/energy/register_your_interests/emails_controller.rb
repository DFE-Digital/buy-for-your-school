module Energy
  module RegisterYourInterests
    class EmailsController < BaseController
      before_action { @registration.step = "email" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_path) }

      def index; end

      def create
        save_step("email", registration_params(:email), energy_register_your_interest_phone_number_path)
      end
    end
  end
end
