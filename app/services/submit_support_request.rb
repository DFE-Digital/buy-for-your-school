# frozen_string_literal: true

require "dry-initializer"
require "types"

#
# This will become an API call once Supported is standalone
#
# /api/v1/support-enquiries/new
#
# @example Draft API call
#
#   ```json
#   {
#     "support_enquiry": [{
#       "support_request_id":1,
#       "name":"Confused SBP",
#       "email":"sbp@school.gov.uk",
#       "telephone": "01234567890"
#       "message": "example message",
#       "documents" : [{
#          "file_type": "html_markup",
#          "document_body": "<h1>example html markup</h1>"
#        }]
#     }]
#   }
#   ```
#
# Submit a request for support to the Supported case management team
class SubmitSupportRequest
  extend Dry::Initializer

  option :request
  option :template, Types::String, default: proc { "Auto-reply" }

  # TODO: Replace with outbound API call
  #
  # @return [nil, Notifications::Client::ResponseNotification]
  def call
    return false unless enquiry

    Emails::Confirmation.new(
      recipient: request.user,
      # reference: "WIP", # NB: propose tracking Notify using the case ref
      template: template,
      variables: {
        support_query: request.message_body,
        category: category,
        case_ref: "WIP",
      },
    ).call
  end

private

  # @return [String] snapshot of specification HTML
  def document_body
    SpecificationRenderer.new(journey: request.journey, to: :html).call
  end

  # @return [String] category of spend
  def category
    request.journey ? request.journey.category.slug : request.category.slug
  end

  # API (draft) ----------------------------------------------------------------

  # @return [Support::Enquiry] TODO: Move into inbound API
  def enquiry
    enquiry = Support::Enquiry.new(
      support_request_id: request.id,
      name: request.user.full_name,
      email: request.user.email,
      telephone: request.phone_number,
      message: request.message_body,
      category: category,
      # TODO: include unique identifier for school
    )

    enquiry.documents << document if request.journey
    enquiry.save!
  end

  # @return [Support::Document] TODO: Move into inbound API
  def document
    Support::Document.new(file_type: "HTML attachment", document_body: document_body)
  end
end
