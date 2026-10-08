module Energy
  module RegisterYourInterests
    class NamesController < BaseController
      before_action(only: :index) { @registration.step = "name" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_path) if editing_answers? }

      def index
        @registration.step = "name"
      end

      def create
        save_step("name", registration_params(:name), energy_register_your_interest_email_path)
      end
    end
  end
end
