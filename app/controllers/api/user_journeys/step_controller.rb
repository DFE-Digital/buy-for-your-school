module Api
  module UserJourneys
    class StepController < Api::BaseController
      def create
        user_journey = UserJourney.find_or_create_new_in_progress_by(session_id: step_params[:sessionId])
        user_journey.update!(referral_campaign: step_params[:referralCampaign])
        user_journey.record_step(product_section: step_params[:productSection], step_description: step_params[:stepDescription])
      end

    private

      def step_params
        params.permit(:sessionId, :productSection, :stepDescription, :referralCampaign)
      end
    end
  end
end
