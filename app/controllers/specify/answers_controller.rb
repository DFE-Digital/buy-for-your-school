# frozen_string_literal: true

# TODO: refactor AnswersController as ResponseController
class Specify::AnswersController < Specify::ApplicationController
  before_action :check_user_belongs_to_journey?

  include DateHelper
  include AnswerHelper

  # Redirect to:
  #  - task only step completed  -> journey
  #  - task all steps completed  -> task
  #  - task incomplete           -> step
  #
  # Log 'save_answer'
  #
  # @see SaveAnswer
  def create
    @journey = current_journey

    @answer = AnswerFactory.new(step:).call
    @answer.step = step.__getobj__

    result = SaveAnswer.new(answer: step.answer).call(params: prepared_params(step:))
    @answer = result.object

    @back_url =
      if !step.task || step.task.has_single_visible_step?
        journey_path(@journey, anchor: step.id, back_link: true)
      else
        journey_task_path(@journey, step.task, back_link: true)
      end

    record_action("save_answer", { success: result.success? })

    if result.success?
      step.unskip! if step.skipped?

      if parent_task.has_single_visible_step?
        redirect_to journey_path(@journey, anchor: step.id)
      elsif parent_task.all_steps_completed? || step.last?
        redirect_to journey_task_path(@journey, parent_task)
      else
        redirect_to journey_step_path(@journey, parent_task.next_incomplete_step_id)
      end
    else
      render "specify/steps/#{step.contentful_type}", locals: { layout: "specify/steps/new_form_wrapper" }
    end
  end

  # Log 'update_answer'
  #
  # @see SaveAnswer
  def update
    @journey = current_journey

    result =
      if step.question?
        # Save the question answer
        SaveAnswer.new(answer: step.answer).call(params: prepared_params(step:))
      elsif step.statement?
        # Acknowledge the statement
        step.task.statement_ids << step.id unless step.task.statement_ids.include?(step.id)
        record_action("acknowledge_statement", nil)
        Result.new(step.task.save!)
      end

    @answer = result.object

    record_action("update_answer", { success: result.success? })

    if result.success?
      if parent_task.has_single_visible_step?
        redirect_to journey_path(@journey, anchor: step.id)
      else
        redirect_to journey_task_path(@journey, parent_task)
      end
    else
      render "specify/steps/#{step.contentful_type}", locals: { layout: "specify/steps/edit_form_wrapper" }
    end
  end

private

  def record_action(action, data)
    RecordAction.new(
      action:,
      journey_id: @journey.id,
      user_id: current_user.id,
      # We safe navigate here because in preview we don't have sections or
      # tasks. This saves us from having to implement extra logic.
      contentful_category_id: @journey.category&.contentful_id,
      contentful_category: @journey.category&.title,
      contentful_section_id: step.task&.section&.contentful_id,
      contentful_section: step.task&.section&.title,
      contentful_task_id: step&.task&.contentful_id,
      contentful_task: step&.task&.title,
      contentful_step_id: step.contentful_id,
      contentful_step: step.title,
      data:,
    ).call
  end

  def step
    @step ||= StepPresenter.new(Step.find(step_id))
  end

  # @return [Task]
  def parent_task
    step.task
  end

  # @return [String]
  def step_id
    params[:step_id]
  end

  # @param step [Step]
  #
  # @return [Hash]
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

  # Validate answer params
  #
  # @return [Hash]
  # @raise [ActionController::ParameterMissing]
  def answer_params
    params.require(:answer).permit(:response, :further_information)
  end

  # Build machine-readable `further_information` value for {CheckboxAnswers} and {RadioAnswer}
  #
  # @see AnswerHelper
  #
  # @return [ActionController::Parameters]
  # @raise [ActionController::ParameterMissing]
  def further_information_params
    return { skipped: true, response: [""], further_information: nil } if skip_answer?

    answer_params = params.require(:answer)

    # [{"value"=>"Catering"}, {"value"=>"Cleaning"}]
    if step.options
      # %i[catering_further_information cleaning_further_information]
      allowed_further_information_keys = step.options.map do |option|
        key = machine_readable_option(string: option["value"])
        "#{key}_further_information".to_sym
      end
    end

    further_information_params = answer_params.permit(*allowed_further_information_keys)
    further_information = further_information_params.to_hash

    all_params = answer_params.permit(:response, response: [])
    all_params[:further_information] = further_information

    if step.contentful_type == "checkboxes"
      all_params[:skipped] = false
    end

    all_params
  end

  # @see DateHelper
  #
  # @return [Hash<Symbol>] { response: Date }
  def date_params
    answer = params.require(:answer).permit(:response)
    date_hash = { day: answer["response(3i)"], month: answer["response(2i)"], year: answer["response(1i)"] }
    { response: format_date(date_hash) }
  end

  # Specific to checkboxes
  #
  # @return [Boolean]
  def skip_answer?
    params.fetch("skip", false)
  end
end
