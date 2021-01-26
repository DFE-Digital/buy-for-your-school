# frozen_string_literal: true

class StepsController < ApplicationController
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
