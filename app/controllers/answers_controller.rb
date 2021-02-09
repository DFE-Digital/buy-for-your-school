# frozen_string_literal: true

class AnswersController < ApplicationController
  def create
    @journey = Journey.find(journey_id)
    @step = Step.find(step_id)

    @answer = AnswerFactory.new(step: @step).call
    @answer.step = @step

    case @step.contentful_type
    when "checkboxes"
      @answer.assign_attributes(checkbox_params)
    else
      @answer.assign_attributes(answer_params)
    end
    
    if @answer.valid?
      @answer.save
      redirect_to journey_path(@journey)
    else
      render "steps/#{@step.contentful_type}", locals: {layout: "steps/new_form_wrapper"}
    end
  end

  def update
    @journey = Journey.find(journey_id)
    @step = Step.find(step_id)
    @answer = @step.answer

    case @step.contentful_type
    when "checkboxes"
      @answer.assign_attributes(checkbox_params)
    else
      @answer.assign_attributes(answer_params)
    end

    if @answer.valid?
      @answer.save
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
    params.require(:answer).permit(response: [])
  end
end
