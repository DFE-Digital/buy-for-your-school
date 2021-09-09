# frozen_string_literal: true

class SpecificationsController < ApplicationController
  breadcrumb "Dashboard", :dashboard_path

  before_action :check_user_belongs_to_journey?

  # Render HTML and DOCX formats
  #
  # Log 'view_specification'
  #
  # @see SpecificationRenderer
  def show
    breadcrumb "Create Specification", journey_path(current_journey), match: :exact
    breadcrumb "View Specification", journey_specification_path(current_journey), match: :exact
    @journey = current_journey

    specification_renderer = SpecificationRenderer.new(
      template: @journey.category.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: @journey.steps).call,
    )

    RecordAction.new(
      action: "view_specification",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
      data: {
        format: request.format.symbol,
        all_tasks_completed: @journey.all_tasks_completed?,
      },
    ).call

    @specification_html = specification_renderer.to_html

    respond_to do |format|
      format.html
      format.docx do
        file_name = @journey.all_tasks_completed? ? "specification.docx" : "specification-incomplete.docx"
        document_html = specification_renderer.to_document_html(journey_complete: @journey.all_tasks_completed?)

        render docx: file_name, content: document_html
      end
    end
  end
end
