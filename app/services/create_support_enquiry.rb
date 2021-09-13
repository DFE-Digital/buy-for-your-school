# Service to create a support enquiry after_commit of a Support Request
# This should be refactored to an API call if/when specify and support become independent applications.

class CreateSupportEnquiry

  # @param [support_request][SupportRequest] SupportRequest Object

  def initialize(support_request)
    @support_request = support_request
  end

  def call
    Support::Enquiry.create(
      support_request_id: @support_request.id,
      name: @support_request.user&.full_name,
      email: @support_request.user&.email,
      telephone: @support_request.phone_number,
      message: @support_request.message,
      documents: [build_document(@support_request)],
    )
  end

private

  def build_document(support_request)
    markup = get_specification_markup(support_request)
    Support::Document.new(file_type: "HTML attachment", document_body: markup)
  end

  def get_specification_markup(support_request)
    specification_renderer = SpecificationRenderer.new(
      template: support_request.journey&.category&.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: @journey.steps).call,
    )

    @specification_html = specification_renderer.to_html
  end

  def send_rollbar_warning
    Rollbar.warning("Couldn't create support enquiry'")
  end
end
