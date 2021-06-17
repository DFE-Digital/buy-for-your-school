# frozen_string_literal: true

class SpecificationsController < ApplicationController
  before_action :check_user_belongs_to_journey?

  def show
    @journey = current_journey
    @visible_steps = @journey.visible_steps
    @step_presenters = @visible_steps.map { |step| StepPresenter.new(step) }

    specification_renderer = SpecificationRenderer.new(
      template: @journey.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: @visible_steps).call
    )

    RecordAction.new(
      action: "view_specification",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      data: {
        format: request.format.symbol,
        all_steps_completed: @journey.all_steps_completed?
      }
    ).call

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
end
