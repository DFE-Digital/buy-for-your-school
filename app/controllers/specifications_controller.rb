# frozen_string_literal: true

class SpecificationsController < ApplicationController
  before_action :check_user_belongs_to_journey?
  before_action :next_steps_path, only: %i[show create]
  helper_method :current_journey, :form

  def new
    @form = DownloadSpecificationForm.new
  end

  def create
    if validation.success?
      if form.finished
        current_journey.finish!
        redirect_to(
          URI::HTTPS.build(
            path: @next_steps_path,
            query: { redirect_url: journey_specification_url(current_journey, format: :docx) }.to_query,
          ).request_uri,
        )
      else
        @redirect_url = journey_specification_url(current_journey, format: :docx)
        render :show
      end
    else
      render :new
    end
  end

  # Render HTML and DOCX formats
  #
  # Log 'view_specification'
  #
  # @see SpecificationRenderer
  def show
    breadcrumb "Dashboard", :dashboard_path
    breadcrumb "Create specification", journey_path(current_journey), match: :exact
    breadcrumb "View specification", journey_specification_path(current_journey), match: :exact

    RecordAction.new(
      action: "view_specification",
      journey_id: current_journey.id,
      user_id: current_user.id,
      contentful_category_id: current_journey.category.contentful_id,
      contentful_category: current_journey.category.title,
      data: {
        format: request.format.symbol,
        all_tasks_completed: current_journey.all_tasks_completed?,
      },
    ).call

    file_name = current_journey.all_tasks_completed? ? "specification.#{file_ext}" : "specification-incomplete.#{file_ext}"

    respond_to do |format|
      format.html
      format.docx do
        document = SpecificationRenderer.new(journey: current_journey).call(draft: !current_journey.finished?)
        send_data document, filename: file_name, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      end
      # format.pdf do
      #   document = SpecificationRenderer.new(journey: current_journey, to: :pdf).call
      #   send_data document, filename: file_name, type: "application/pdf"
      # end
      # format.odt do
      #   document = SpecificationRenderer.new(journey: current_journey, to: :odt).call
      #   send_data document, filename: file_name, type: "application/vnd.oasis.opendocument.text"
      # end
    end
  end

private

  def form
    @form ||= DownloadSpecificationForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def validation
    @validation ||= DownloadSpecificationFormSchema.new.call(**form_params)
  end

  def form_params
    params.require(:form).permit(:finished)
  end

  # @return [String]
  def file_ext
    params[:format]
  end

  def next_steps_path
    @next_steps_path = "/next-steps-#{current_journey.category_slug}"
  end
end
