# frozen_string_literal: true

#
# This will become an API call once Supported is standalone
#
# Submit an FaF request for support to the Supported case management team
class SubmitFrameworkRequest
  extend Dry::Initializer

  # @!attribute request
  #   @return [FrameworkRequestPresenter]
  option :request, ::Types.Constructor(FrameworkRequestPresenter)

  # @!attribute template
  #   @return [String] Template UUID
  option :template, Types::String, default: proc { "621a9fe9-018c-425e-ae6e-709c6718fe8d" }

  # @!attribute referer
  #   @return [String]
  option :referer

  # TODO: Replace with outbound API call
  #
  # @return [false, Notifications::Client::ResponseNotification]
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
      },
    ).call

    # TODO: save case reference to the request
    request.update!(submitted: true)
  end

private

  def user
    @user ||= FrameworkRequestPresenter.new(request).user
  end

  # @return [Support::Organisation, Support::EstablishmentGroup]
  def map_organisation
    if request.group
      Support::EstablishmentGroup.find_by(uid: request.org_id)
    else
      Support::Organisation.find_by(urn: request.org_id)
    end
  end

  # @return [Support::Case] TODO: Move into inbound API
  def open_case
    kase_attrs = {
      organisation: map_organisation,
      source: "faf",
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      request_text: request.message_body,
    }

    @kase = Support::CreateCase.new(kase_attrs).call

    interaction_attrs = {
      additional_data: {
        "support_request_id": request.id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "message": request.message_body,
        "referer": referer,
      },
    }
    Support::CreateInteraction.new(@kase.id, "faf_support_request", nil, interaction_attrs).call

    @kase
  end
end
