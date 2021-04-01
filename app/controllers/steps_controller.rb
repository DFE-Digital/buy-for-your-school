# frozen_string_literal: true

class StepsController < ApplicationController
  before_action :check_user_belongs_to_journey?

  def show
    @journey = current_journey

    @step = Step.find(params[:id])
    @step_presenter = StepPresenter.new(@step)

    @answer = AnswerFactory.new(step: @step).call

    render @step.contentful_type, locals: {layout: "steps/new_form_wrapper"}
  end

  def edit
    @journey = current_journey

    @step = Step.find(params[:id])
    @step_presenter = StepPresenter.new(@step)

    @answer = @step.answer

    render "steps/#{@step.contentful_type}", locals: {layout: "steps/edit_form_wrapper"}
  end

  private

  def journey_id
    params[:journey_id]
  end
end
