# frozen_string_literal: true

class StepsController < ApplicationController
  before_action :check_user_belongs_to_journey?

  # Log 'begin_step'
  #
  # @see StepPresenter
  def show
    @journey = current_journey
    # TODO: wrap the step in its delegator presenter and update instance variable in templates
    @step = Step.find(params[:id])
    @step_presenter = StepPresenter.new(@step)

    @answer = AnswerFactory.new(step: @step).call
    # TODO: extract @back_url to a shared private method
    @back_url =
      if !parent_task || parent_task.has_single_visible_step?
        journey_path(@journey, anchor: @step.id, back_link: true)
      else
        journey_task_path(@journey, parent_task, back_link: true)
      end

    flash[:preview] = "This is a preview" if params.key?(:preview)

    RecordAction.new(
      action: "begin_step",
      journey_id: @journey.id,
      user_id: current_user.id,
      # We safe navigate here because in preview we don't have sections or
      # tasks. This saves us from having to implement extra logic.
      contentful_category_id: @journey.category&.contentful_id,
      contentful_section_id: @step.task&.section&.contentful_id,
      contentful_task_id: @step&.task&.contentful_id,
      contentful_step_id: @step.contentful_id,
    ).call

    render @step.contentful_type, locals: { layout: "steps/new_form_wrapper" }
  end

  # Log 'view_step'
  #
  # @see StepPresenter
  def edit
    @journey = current_journey

    # TODO: wrap the step in its delegator presenter and update instance variable in templates
    @step = Step.find(params[:id])
    @step_presenter = StepPresenter.new(@step)

    @answer = @step.answer
    # TODO: extract @back_url to a shared private method
    @back_url =
      if !parent_task || parent_task.has_single_visible_step?
        journey_path(@journey, anchor: @step.id, back_link: true)
      else
        journey_task_path(@journey, parent_task, back_link: true)
      end

    RecordAction.new(
      action: "view_step",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
      contentful_section_id: @step.task.section.contentful_id,
      contentful_task_id: @step.task.contentful_id,
      contentful_step_id: @step.contentful_id,
    ).call

    render "steps/#{@step.contentful_type}", locals: { layout: "steps/edit_form_wrapper" }
  end

  def update
    @journey = current_journey
    @step = Step.find(params[:id])

    parent_task.skipped_ids << @step.id unless parent_task.skipped_ids.include?(@step.id)
    parent_task.save!

    if parent_task.has_single_visible_step?
      redirect_to journey_path(@journey, anchor: @step.id)
    elsif parent_task.all_unanswered_questions_skipped?
      next_step_id = parent_task.next_skipped_id(@step.id)
      if next_step_id.nil?
        redirect_to journey_task_path(@journey, parent_task)
      else
        redirect_to journey_step_path(@journey, next_step_id)
      end
    else
      redirect_to journey_step_path(@journey, parent_task.next_incomplete_step_id)
    end
  end

private

  def parent_task
    @step.task
  end
end
