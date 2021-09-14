# Service to create a support enquiry after_commit of a Support Request
# This should be refactored to an API call if/when specify and support become independent applications.
# It makes sense for this service to live within specify as it is the event of a SupportEnquiry being
# created that triggers the creation of a Support::Enquiry

class CreateSupportEnquiry
  # @param [support_request][SupportRequest] SupportRequest Object

  def initialize(support_request)
    @support_request = support_request
  end

  # @return [Support::Enquiry]
  def call
    enquiry = Support::Enquiry.new(
      support_request_id: @support_request.id,
      name: @support_request.user&.full_name,
      email: @support_request.user&.email,
      telephone: @support_request.phone_number,
      message: @support_request.message,
    )
    if build_document(@support_request).present?
      enquiry.documents << build_document(@support_request)
    end

    enquiry.save!
    enquiry
  end

private

  # Creates document attachment to attach to a Support::Enquiry.
  # @return [Support::Document]
  def build_document(support_request)
    return if support_request.journey.blank?

    markup = get_specification_markup(support_request)
    Support::Document.new(file_type: "HTML attachment", document_body: markup)
  end

  # Returns HTML string of the specification to pass along to supported.
  # @return [String]
  def get_specification_markup(support_request)
    specification_renderer = SpecificationRenderer.new(
      template: support_request.journey&.category&.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: support_request.journey&.steps).call,
    )

    @specification_html = specification_renderer.to_html
  end
end
