# frozen_string_literal: true

class AnswersController < ApplicationController
  include DateHelper
  include AnswerHelper

  def create
    @journey = Journey.find(journey_id)
    @step = Step.find(step_id)
    @step_presenter = StepPresenter.new(@step)

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
    @step_presenter = StepPresenter.new(@step)

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
    return {skipped: true, response: [""], further_information: nil} if skip_answer?

    answer_params = params.require(:answer)

    if @step.options
      allowed_further_information_keys = @step.options.map { |option|
        key = machine_readable_option(string: option["value"])
        "#{key}_further_information".to_sym
      }
    end

    further_information_params = answer_params.permit(*allowed_further_information_keys)
    further_information = further_information_params.to_hash

    all_params = answer_params.permit(response: [])
    all_params[:further_information] = further_information
    all_params
  end

  def date_params
    answer = params.require(:answer).permit(:response)
    date_hash = {day: answer["response(3i)"], month: answer["response(2i)"], year: answer["response(1i)"]}
    {response: format_date(date_hash)}
  end

  def skip_answer?
    params.fetch("skip", false)
  end
end
