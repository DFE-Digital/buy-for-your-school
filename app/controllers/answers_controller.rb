# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :check_user_belongs_to_journey?

  include DateHelper
  include AnswerHelper

  def create
    @journey = current_journey
    @step = Step.find(step_id)
    @step_presenter = StepPresenter.new(@step)

    @answer = AnswerFactory.new(step: @step).call
    @answer.step = @step

    result = SaveAnswer.new(answer: @step.answer).call(params: prepared_params(step: @step))
    @answer = result.object

    RecordAction.new(
      action: "save_answer",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      contentful_section_id: @step.task.section.contentful_id,
      contentful_task_id: @step.task.contentful_id,
      contentful_step_id: @step.contentful_id,
      data: {
        success: result.success?
      }
    ).call

    if result.success?
      if parent_task.has_single_visible_step?
        redirect_to journey_path(@journey, anchor: @step.id)
      elsif parent_task.all_steps_answered?
        redirect_to journey_task_path(@journey, parent_task)
      else
        redirect_to journey_step_path(@journey, parent_task.next_unanswered_step_id)
      end
    else
      render "steps/#{@step.contentful_type}", locals: {layout: "steps/new_form_wrapper"}
    end
  end

  def update
    @journey = current_journey
    @step = Step.find(step_id)
    @step_presenter = StepPresenter.new(@step)

    result = SaveAnswer.new(answer: @step.answer).call(params: prepared_params(step: @step))
    @answer = result.object

    RecordAction.new(
      action: "update_answer",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      contentful_section_id: @step.task.section.contentful_id,
      contentful_task_id: @step.task.contentful_id,
      contentful_step_id: @step.contentful_id,
      data: {
        success: result.success?
      }
    ).call

    if result.success?
      if parent_task.has_single_visible_step?
        redirect_to journey_path(@journey, anchor: @step.id)
      else
        redirect_to journey_task_path(@journey, parent_task)
      end
    else
      render "steps/#{@step.contentful_type}", locals: {layout: "steps/edit_form_wrapper"}
    end
  end

  private

  def parent_task
    @step.task
  end

  def step_id
    params[:step_id]
  end

  def prepared_params(step:)
    case step.contentful_type
    when "checkboxes", "radios"
      further_information_params
    when "single_date"
      date_params
    else
      answer_params
    end
  end

  def answer_params
    params.require(:answer).permit(:response, :further_information)
  end

  def further_information_params
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

    all_params = answer_params.permit(:response, response: [])
    all_params[:further_information] = further_information

    if @step.contentful_type == "checkboxes"
      all_params[:skipped] = false
    end

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
