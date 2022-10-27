module Api
  module UserJourneys
    class StepController < Api::BaseController
      def create
        user_journey = get_user_journey
        ::UserJourneys::CreateStep.new(
          step_description: step_params[:stepDescription],
          product_section: step_params[:productSection],
          user_journey_id: user_journey.id,
          session_id: step_params[:sessionId],
        ).call
      end

    private

      def step_params
        params.permit(:sessionId, :productSection, :stepDescription, :referralCampaign)
      end

      def get_user_journey
        ::UserJourneys::GetOrCreate.new(
          session_id: step_params[:sessionId],
          referral_campaign: step_params[:referralCampaign],
        ).call
      end
    end
  end
end
