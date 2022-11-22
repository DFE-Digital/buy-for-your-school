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

  # @!attribute referrer
  #   @return [String]
  option :referrer

  # TODO: Replace with outbound API call
  #
  # @return [false, Notifications::Client::ResponseNotification]
  def call
    return false unless open_case

    send_confirmation_email

    UserJourney
      .find_by(framework_request_id: request.id)
      .try(:update!, case: @kase, status: :case_created)

    CaseFiles::SubmitEnergyBills.new
      .call(framework_request_id: request.id, support_case_id: @kase.id)

    request.update!(submitted: true)
  end

private

  def user
    @user ||= FrameworkRequestPresenter.new(request).user
  end

  # @return [Support::Case] TODO: Move into inbound API
  def open_case
    kase_attrs = {
      organisation: request.organisation,
      source: "faf",
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      request_text: request.message_body,
      procurement_amount: request.__getobj__.procurement_amount,
      special_requirements: request.special_requirements.presence,
      category_id: detected_category_id,
      detected_category_id:,
    }

    @kase = Support::CreateCase.new(kase_attrs).call

    interaction_attrs = {
      additional_data: {
        "support_request_id": request.id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "message": request.message_body,
        "referrer": referrer,
        "detected_category_id": detected_category_id,
        "bills": request.bill_filenames,
      },
    }
    Support::CreateInteraction.new(@kase.id, "faf_support_request", nil, interaction_attrs).call

    @kase
  end

  def detected_category_id
    @results ||= Support::CategoryDetection.results_for(request.message_body, is_energy_request: request.is_energy_request, num_results: 1)
    @results.first.try(:category_id) if @results.any?
  end

  def send_confirmation_email
    if request.has_bills? || request.energy_alternative == "email_later"
      Emails::ConfirmationEnergy.new(
        recipient: request.user,
        reference: @kase.ref,
        variables: {
          message: request.message_body,
        },
      ).call
    else
      Emails::Confirmation.new(
        recipient: request.user,
        reference: @kase.ref,
        template:,
        variables: {
          message: request.message_body,
        },
      ).call
    end
  end
end
