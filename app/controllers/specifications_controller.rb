# frozen_string_literal: true

class SpecificationsController < ApplicationController
  before_action :check_user_belongs_to_journey?

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

    specification_renderer = SpecificationRenderer.new(
      template: @journey.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: @visible_steps).call
    )

    @specification_html = specification_renderer.to_html

    respond_to do |format|
      format.html
      format.docx do
        file_name = @journey.all_steps_completed? ? "specification.docx" : "specification-incomplete.docx"
        document_html = specification_renderer.to_document_html(journey_complete: @journey.all_steps_completed?)

        render docx: file_name, content: document_html
      end
    end
  end

  private

  def journey_id
    params[:journey_id]
  end
end
