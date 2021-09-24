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
    @journey = JourneyPresenter.new(current_journey)

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

    file_name = @journey.all_tasks_completed? ? "specification.#{file_ext}" : "specification-incomplete.#{file_ext}"

    respond_to do |format|
      format.html
      format.docx do
        document = SpecificationRenderer.new(journey: @journey).call
        send_data document, filename: file_name, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      end
      # format.pdf do
      #   document = SpecificationRenderer.new(journey: @journey, to: :pdf).call
      #   send_data document, filename: file_name, type: "application/pdf"
      # end
      # format.odt do
      #   document = SpecificationRenderer.new(journey: @journey, to: :odt).call
      #   send_data document, filename: file_name, type: "application/vnd.oasis.opendocument.text"
      # end
    end
  end

private

  # @return [String]
  def file_ext
    params[:format]
  end
end
