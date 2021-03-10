# frozen_string_literal: true

class SpecificationsController < ApplicationController
  def show
    @journey = Journey.find(journey_id)
    @visible_steps = @journey.visible_steps.includes([
      :radio_answer,
      :short_text_answer,
      :long_text_answer,
      :single_date_answer,
      :checkbox_answers,
      :number_answer,
      :currency_answer
    ])
    @step_presenters = @visible_steps.map { |step| StepPresenter.new(step) }

    @specification_template = Liquid::Template.parse(
      @journey.liquid_template, error_mode: :strict
    )

    @answers = GetAnswersForSteps.new(visible_steps: @visible_steps).call
    @specification_html = @specification_template.render(@answers)

    respond_to do |format|
      format.html
      format.docx do
        render docx: "specification.docx", content: @specification_html
      end
    end
  end

  private

  def journey_id
    params[:journey_id]
  end
end
