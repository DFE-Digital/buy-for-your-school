# frozen_string_literal: true

class JourneysController < ApplicationController
  def new
    journey = Journey.create(category: "catering", next_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"])
    redirect_to new_journey_question_path(journey)
  end

  def show
    @journey = Journey.includes(
      questions: [:radio_answer, :short_text_answer]
    ).find(journey_id)
  end

  private

  def journey_id
    params[:id]
  end
end
