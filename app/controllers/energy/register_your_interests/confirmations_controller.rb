module Energy
  module RegisterYourInterests
    class ConfirmationsController < BaseController
      def show
        redirect_to energy_register_your_interest_path unless @registration.submitted?
      end
    end
  end
end
