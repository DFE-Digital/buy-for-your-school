# frozen_string_literal: true

class AnswersController < ApplicationController
  include DateHelper

  def create
    @journey = Journey.find(journey_id)
    @step = Step.find(step_id)

    @answer = AnswerFactory.new(step: @step).call
    @answer.step = @step

    result = SaveAnswer.new(answer: @answer)
      .call(checkbox_params: checkbox_params, answer_params: answer_params, date_params: date_params)
    @answer = result.object

    if result.success?
      redirect_to journey_path(@journey)
    else
      render "steps/#{@step.contentful_type}", locals: {layout: "steps/new_form_wrapper"}
    end
  end

  def update
    @journey = Journey.find(journey_id)
    @step = Step.find(step_id)

    result = SaveAnswer.new(answer: @step.answer)
      .call(checkbox_params: checkbox_params, answer_params: answer_params, date_params: date_params)
    @answer = result.object

    if result.success?
      redirect_to journey_path(@journey)
    else
      render "steps/#{@step.contentful_type}", locals: {layout: "steps/edit_form_wrapper"}
    end
  end

  private

  def journey_id
    params[:journey_id]
  end

  def step_id
    params[:step_id]
  end

  def answer_params
    params.require(:answer).permit(:response, :further_information)
  end

  def checkbox_params
    params.require(:answer).permit(:further_information, response: [])
  end

  def date_params
    answer = params.require(:answer).permit(:response)
    date_hash = {day: answer["response(3i)"], month: answer["response(2i)"], year: answer["response(1i)"]}
    {response: format_date(date_hash)}
  end
end
