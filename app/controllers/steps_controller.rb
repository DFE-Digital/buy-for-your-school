# frozen_string_literal: true

class StepsController < ApplicationController
  rescue_from GetContentfulEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  rescue_from CreateJourneyStep::UnexpectedContentfulModel do |exception|
    render "errors/unexpected_contentful_model", status: 500
  end

  rescue_from CreateJourneyStep::UnexpectedContentfulStepType do |exception|
    render "errors/unexpected_contentful_step_type", status: 500
  end

  def new
    @journey = Journey.find(journey_id)

    return redirect_to journey_path(@journey) unless @journey.next_entry_id.present?

    contentful_entry = GetContentfulEntry.new(entry_id: @journey.next_entry_id).call
    @step = CreateJourneyStep.new(
      journey: @journey, contentful_entry: contentful_entry
    ).call

    redirect_to journey_step_path(@journey, @step)
  end

  def show
    @journey = Journey.find(journey_id)
    @step = Step.find(params[:id])
    @answer = AnswerFactory.new(step: @step).call

    render @step.contentful_type, locals: {layout: "steps/new_form_wrapper"}
  end

  def edit
    @journey = Journey.find(journey_id)
    @step = Step.find(params[:id])
    @answer = @step.answer

    render "steps/#{@step.contentful_type}", locals: {layout: "steps/edit_form_wrapper"}
  end

  private

  def journey_id
    params[:journey_id]
  end
end
