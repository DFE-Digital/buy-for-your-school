module UserJourneys
  class CreateStep
    def initialize(
      step_description:,
      product_section:,
      user_journey_id:,
      session_id:
    )
      @step_description = step_description
      @product_section = product_section
      @user_journey_id = user_journey_id
      @session_id = session_id
    end

    def call
      UserJourneyStep.create!(
        step_description: @step_description,
        product_section: @product_section,
        user_journey_id: @user_journey_id,
        session_id: @session_id,
      )
    end
  end
end
