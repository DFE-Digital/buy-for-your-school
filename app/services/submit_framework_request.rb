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

  # @return [Support::Organisation, Support::EstablishmentGroup]
  def map_organisation
    if request.group
      Support::EstablishmentGroup.find_by(uid: request.org_id)
    else
      Support::Organisation.find_by(urn: request.org_id)
    end
  end

  def map_urns_to_orgs(urns)
    urns.map { |urn| Support::Organisation.find_by(urn:) }
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
      procurement_amount: request.__getobj__.procurement_amount,
      special_requirements: request.special_requirements.presence,
      category_id: request.category&.support_category&.id,
      other_category: request.category_other,
      user_selected_category:,
      detected_category_id: request.category&.support_category&.id,
      participating_schools: map_urns_to_orgs(request.school_urns),
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
        "bills": request.bill_filenames,
      },
    }
    Support::CreateInteraction.new(@kase.id, "faf_support_request", nil, interaction_attrs).call

    @kase
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

  def user_selected_category
    return if request.category.nil?

    result = request.category.hierarchy.map(&:title).join("/")
    result = "#{result} - #{request.category_other}" if request.category_other.present?
    result
  end
end
