# frozen_string_literal: true

class StepsController < ApplicationController
  before_action :check_user_belongs_to_journey?

  def show
    @journey = current_journey

    @step = Step.find(params[:id])
    @step_presenter = StepPresenter.new(@step)

    @answer = AnswerFactory.new(step: @step).call
    @back_url = if !parent_task || parent_task.has_single_visible_step?
      journey_path(@journey, anchor: @step.id, back_link: true)
    else
      journey_task_path(@journey, parent_task, back_link: true)
    end

    RecordAction.new(
      action: "begin_step",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      # We safe navigate here because in preview we don't have sections or
      # tasks. This saves us from having to implement extra logic.
      contentful_section_id: @step.task&.section&.contentful_id,
      contentful_task_id: @step&.task&.contentful_id,
      contentful_step_id: @step.contentful_id
    ).call

    render @step.contentful_type, locals: {layout: "steps/new_form_wrapper"}
  end

  def edit
    @journey = current_journey

    @step = Step.find(params[:id])
    @step_presenter = StepPresenter.new(@step)

    @answer = @step.answer
    @back_url = if !parent_task || parent_task.has_single_visible_step?
      journey_path(@journey, anchor: @step.id, back_link: true)
    else
      journey_task_path(@journey, parent_task, back_link: true)
    end

    RecordAction.new(
      action: "view_step",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      contentful_section_id: @step.task.section.contentful_id,
      contentful_task_id: @step.task.contentful_id,
      contentful_step_id: @step.contentful_id
    ).call

    render "steps/#{@step.contentful_type}", locals: {layout: "steps/edit_form_wrapper"}
  end

  private

  def parent_task
    @step.task
  end
end
