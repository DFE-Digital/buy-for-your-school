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
    breadcrumb "Create specification", journey_path(current_journey), match: :exact
    breadcrumb "View specification", journey_specification_path(current_journey), match: :exact
    @journey = current_journey

    specification = SpecificationRenderer.new(
      template: @journey.category.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: @journey.steps).call,
    ).markdown

    document_formatter = DocumentFormatter.new(markdown: specification)

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

    respond_to do |format|
      format.html
      format.docx do
        file_name = @journey.all_tasks_completed? ? "specification.docx" : "specification-incomplete.docx"
        document = document_formatter.call(draft: !@journey.all_tasks_completed?)

        send_data document, filename: file_name, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      end
    end
  end
end
