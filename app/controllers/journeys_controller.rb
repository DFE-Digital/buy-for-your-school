# frozen_string_literal: true

class JourneysController < ApplicationController
  def new
    journey = CreateJourney.new(category: "catering").call
    redirect_to new_journey_step_path(journey)
  end

  def show
    @journey = Journey.includes(
      steps: [:radio_answer, :short_text_answer, :long_text_answer]
    ).find(journey_id)
    @steps = @journey.steps.map { |step| StepPresenter.new(step) }
  end

  private

  def journey_id
    params[:id]
  end
end
