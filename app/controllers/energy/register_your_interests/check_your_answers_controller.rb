module Energy
  module RegisterYourInterests
    class CheckYourAnswersController < BaseController
      before_action { @registration.step = "check-answers" }
      before_action(only: :show) { set_back_url(energy_register_your_interest_electricity_path) }

      def show
        if @registration.submitted?
          redirect_to energy_register_your_interest_confirmation_path
        else
          @registration.valid?
        end
      end

      def update
        @registration.step = "check-answers"
        if @registration.valid?
          @registration.update!(status: :submitted)
          redirect_to energy_register_your_interest_confirmation_path
        else
          redirect_to energy_register_your_interest_check_your_answers_path
        end
      end
    end
  end
end
