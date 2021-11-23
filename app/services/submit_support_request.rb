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
#       "support_request_id":1,
#       "name":"Confused SBP",
#       "email":"sbp@school.gov.uk",
#       "telephone": "01234567890",
#       "message": "example message",
#       "documents": [{
#          "file_type": "html_markup",
#          "document_body": "<h1>example html markup</h1>"
#        }]
#   }
#   ```
#
# Submit a request for support to the Supported case management team
class SubmitSupportRequest
  extend Dry::Initializer

  # @!attribute [r] request
  # @return [SupportRequestPresenter]
  option :request, ::Types.Constructor(SupportRequestPresenter)
  # @!attribute [r] template
  # @return [String] (defaults to Auto-reply)
  option :template, Types::String, default: proc { "Auto-reply" }

  # TODO: Replace with outbound API call
  #
  # @return [nil, Notifications::Client::ResponseNotification]
  def call
    return false unless open_case

    # TODO: confirmation message body forms the first CM interaction
    # email = Emails::Confirmation.new().call
    # message = email.content["body"]
    #
    Emails::Confirmation.new(
      recipient: request.user,
      reference: @kase.ref,
      template: template,
      variables: {
        message: request.message_body,
        category: category,
      },
    ).call

    request.update!(submitted: true)
  end

private

  # @return [nil, String] snapshot of specification HTML
  def document_body
    return nil unless request.journey

    SpecificationRenderer.new(journey: request.journey, to: :html).call
  end

  # @return [String] category of spend
  def category
    request.journey ? request.journey.category.slug : request.category.slug
  end

  def user
    User.find(request.user_id)
  end

  # @return [Support::Document] TODO: Move into inbound API
  def document
    Support::Document.new(file_type: "HTML attachment", document_body: document_body)
  end

  # @return [Support::Category]
  def map_category
    Support::Category.find_by(slug: category)
  end

  # @return [Support::Case] TODO: Move into inbound API
  def open_case
    @kase = Support::Case.create!(request_text: request.message_body,
                                  first_name: user.first_name,
                                  last_name: user.last_name,
                                  email: user.email,
                                  phone_number: request.phone_number,
                                  organisation_urn: request.school_urn,
                                  organisation_name: request.school_name,
                                  category: map_category)

    record_case_opening

    Support::Interaction.create!({  case: @kase,
                                    event_type: 4,
                                    additional_data:
                                      { "support_request_id": request.id,
                                        "first_name": user.first_name,
                                        "last_name": user.last_name,
                                        "email": user.email,
                                        "phone_number": request.phone_number,
                                        "category": category,
                                        "message": request.message_body } })

    @kase.documents << document if request.journey
    @kase
  end

  def record_case_opening
    Support::RecordSupportCaseAction.new(
      support_case_id: @kase.id,
      action: 'opening_case'
    ).call
  end

  # API (draft) ----------------------------------------------------------------
  #
  #   def send_api_request
  #     uri = URI.parse("https://localhost/support/api/create-cases")
  #     http = Net::HTTP.new(uri.host, "3000")
  #     http.use_ssl = true
  #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #     request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
  #     request.body = "{}"
  #     http.request(request)
  #   end
  #
  #   def request_body
  #     { "support_request_id": request.id,
  #       "first_name": user.first_name,
  #       "last_name": user.last_name,
  #       "email": user.email,
  #       "phone_number": request.phone_number,
  #       "category": category,
  #       "message": request.message_body,
  #       "documents": [
  #         { "file_type": "html_markup", "document_body": document_body },
  #       ] }
  #   end
end
