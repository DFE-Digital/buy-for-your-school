module Energy
  module RegisterYourInterests
    class BaseController < ::ApplicationController
      skip_before_action :authenticate_user!
      before_action :load_registration

    private

      def load_registration
        @registration = Energy::RegisterYourInterest.find_by(id: session[:energy_register_your_interest_id])
        @registration ||= Energy::RegisterYourInterest.create!.tap do |registration|
          session[:energy_register_your_interest_id] = registration.id
        end

        redirect_to energy_register_your_interest_confirmation_path if @registration.submitted? && !action_name.in?(%w[show confirmation])
      end

      def save_step(step, attributes, next_path)
        @registration.assign_attributes(attributes)
        @registration.step = step

        if @registration.valid?
          @registration.save!
          redirect_to(editing_answers? ? energy_register_your_interest_check_your_answers_path : next_path)
        else
          render :index, status: :unprocessable_entity
        end
      end

      def registration_params(*attributes)
        params.fetch(:energy_register_your_interest, {}).permit(*attributes)
      end

      def set_back_url(path)
        @back_url = editing_answers? ? energy_register_your_interest_check_your_answers_path : path
      end

      def editing_answers?
        params[:return_to] == "check-answers"
      end
    end
  end
end
