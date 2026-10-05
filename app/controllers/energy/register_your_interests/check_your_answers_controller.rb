module Energy
  module RegisterYourInterests
    class CheckYourAnswersController < BaseController
      before_action { @registration.step = "check-answers" }
      before_action(only: :show) { set_back_url(energy_register_your_interest_electricity_path) }

      def show
        redirect_to energy_register_your_interest_confirmation_path if @registration.submitted?
      end

      def update
        @registration.step = "check-answers"
        if @registration.valid?
          @registration.update!(status: :submitted)
          redirect_to energy_register_your_interest_confirmation_path
        else
          render :show, status: :unprocessable_entity
        end
      end
    end
  end
end
