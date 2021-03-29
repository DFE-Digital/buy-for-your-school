# frozen_string_literal: true

class JourneysController < ApplicationController
  rescue_from GetCategory::InvalidLiquidSyntax do |exception|
    render "errors/specification_template_invalid", status: 500, locals: {error: exception}
  end

  rescue_from CreateJourneyStep::UnexpectedContentfulModel do |exception|
    render "errors/unexpected_contentful_model", status: 500
  end

  rescue_from CreateJourneyStep::UnexpectedContentfulStepType do |exception|
    render "errors/unexpected_contentful_step_type", status: 500
  end

  rescue_from GetEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  def index
    @journeys = Journey.all
  end

  def new
    journey = CreateJourney.new(category_name: "catering", user: current_user).call
    redirect_to journey_path(journey)
  end

  def show
    @journey = Journey.find(journey_id)
    @visible_steps = @journey.visible_steps.includes([
      :radio_answer,
      :short_text_answer,
      :long_text_answer,
      :single_date_answer,
      :checkbox_answers,
      :number_answer,
      :currency_answer
    ])
    @step_presenters = @visible_steps.map { |step| StepPresenter.new(step) }
  end

  private

  def journey_id
    params[:id]
  end
end
