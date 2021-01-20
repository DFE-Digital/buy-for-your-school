# frozen_string_literal: true

class JourneysController < ApplicationController
  rescue_from FindLiquidTemplate::InvalidLiquidSyntax do |exception|
    render "errors/specification_template_invalid", status: 500, locals: {error: exception}
  end

  rescue_from CreateJourneyStep::UnexpectedContentfulModel do |exception|
    render "errors/unexpected_contentful_model", status: 500
  end

  rescue_from CreateJourneyStep::UnexpectedContentfulStepType do |exception|
    render "errors/unexpected_contentful_step_type", status: 500
  end

  rescue_from BuildJourneyOrder::MissingEntryDetected do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  def new
    journey = CreateJourney.new(category: "catering").call
    redirect_to journey_path(journey)
  end

  def show
    @journey = Journey.includes(
      steps: [:radio_answer, :short_text_answer, :long_text_answer, :single_date_answer, :checkbox_answers]
    ).find(journey_id)
    @steps = @journey.steps.map { |step| StepPresenter.new(step) }

    # TODO: Move this logic into a tested class along with a Presenter factory
    @answers = @journey.steps.that_are_questions.each_with_object({}) { |step, hash|
      answer = case step.answer.class.name
      when "ShortTextAnswer" then ShortTextAnswerPresenter.new(step.answer)
      when "LongTextAnswer" then LongTextAnswerPresenter.new(step.answer)
      when "RadioAnswer" then RadioAnswerPresenter.new(step.answer)
      when "SingleDateAnswer" then SingleDateAnswerPresenter.new(step.answer)
      when "CheckboxAnswers" then CheckboxesAnswerPresenter.new(step.answer)
      else
        step.answer
      end
      hash["answer_#{step.contentful_id}"] = answer&.response.to_s
    }

    @specification_template = Liquid::Template.parse(
      @journey.liquid_template, error_mode: :strict
    )

    specification_html = @specification_template.render(@answers)

    respond_to do |format|
      format.html
      format.docx do
        render docx: "specification.docx", content: specification_html, layout: "specficiation"
      end
    end
  end

  private

  def journey_id
    params[:id]
  end
end
