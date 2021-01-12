# frozen_string_literal: true

class JourneysController < ApplicationController
  rescue_from FindLiquidTemplate::InvalidLiquidSyntax do |exception|
    render "errors/specification_template_invalid", status: 500, locals: {error: exception}
  end

  def new
    journey = CreateJourney.new(category: "catering").call
    redirect_to new_journey_step_path(journey)
  end

  def show
    @journey = Journey.includes(
      steps: [:radio_answer, :short_text_answer, :long_text_answer]
    ).find(journey_id)
    @steps = @journey.steps.map { |step| StepPresenter.new(step) }

    @answers = @journey.steps.that_are_questions.each_with_object({}) { |step, hash|
      hash["answer_#{step.contentful_id}"] = step.answer.response.to_s
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
