# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Validate and persist new users and update their DSI details
# Combine auth identity, roles and organisation data from DSI OIDC and API
#
class CreateUser
  extend Dry::Initializer
  include InsightsTrackable

  # @!attribute [r] auth
  # @return [Hash] OmniAuth response
  option :auth, Types::Hash

  # @!attribute [r] client
  # @return [Dsi::Client] DfE Sign In API (defaults to new instance)
  option :client, default: proc { ::Dsi::Client.new }

  # Create or Update the User
  #
  # @return [User, Symbol]
  def call
    return :invalid unless user_id

    update_user! if current_user
    update_support_agent! if current_support_agent.present?
    update_support_evaluator! if current_support_evaluator.present?

    if member_of_a_supported_establishment? || internal_staff_member?
      current_user || create_user!
    elsif orgs.none?
      track_event("CreateUser/UserNotInASupportedOrganisation", reason: "NoOrganisations")
      :no_organisation
    else
      track_event("CreateUser/UserNotInASupportedOrganisation", reason: "NoSupportedOrganisations")
      :unsupported
    end
  end

private

  # @param [String] field
  #
  # @return [Array<Integer>] the current user's org types
  def establishment_types(field)
    orgs.map { |org| org.dig(field, "id").to_i }
  end

  # @return [Boolean] user is affiliated to a "supported establishment"
  def member_of_a_supported_establishment?
    valid_school? || valid_trust?
  end

  # @return [Boolean]
  def valid_school?
    ORG_TYPE_IDS.any? { |id| establishment_types("type").include?(id) }
  end

  # @return [Boolean]
  def valid_trust?
    GROUP_CATEGORY_IDS.any? { |id| establishment_types("category").include?(id) }
  end

  # @return [Boolean] user is a GHBFS or ProcOps team member
  def internal_staff_member?
    current_support_agent.present? || orgs.any? { |org| org["name"] == ENV["PROC_OPS_TEAM"] }
  end

  def current_support_agent
    Support::Agent.where("lower(email) = lower(?)", email).first
  end

  def update_support_agent!
    current_support_agent.update!(dsi_uid: user_id)
    track_event("CreateUser/AgentUpdated", agent_id: current_support_agent.id)
  end

  def current_support_evaluator
    Support::Evaluator.where("lower(email) = lower(?)", email)
  end

  def update_support_evaluator!
    current_support_evaluator.update!(dsi_uid: user_id)
    track_event("CreateUser/EvaluatorUpdated", evaluator_email: email)
  end

  # @return [User, nil]
  def current_user
    User.find_by(dfe_sign_in_uid: user_id)
  end

  # @return [User]
  def update_user!
    current_user.update!(
      email:,
      first_name:,
      last_name:,
      orgs:,
      # Commenting this out for now so it can be restored
      # when we are pulling the roles over from DSI
      # roles: roles,
    )
    track_event("CreateUser/UserUpdated")
    current_user
  end

  # @return [User]
  def create_user!
    user = User.create!(
      dfe_sign_in_uid: user_id,
      email:,
      full_name:,
      first_name:,
      last_name:,
      orgs:,
      # Commenting this out for now so it can be restored
      # when we are pulling the roles over from DSI
      # roles: roles,
    )
    track_event("CreateUser/UserCreated")
    update_support_agent! if current_support_agent
    user
  end

  # @return [String]
  def full_name
    auth.dig("info", "name")
  end

  # @return [String]
  def first_name
    auth.dig("info", "first_name")
  end

  # @return [String]
  def last_name
    auth.dig("info", "last_name")
  end

  # @return [String] Unique identifier for the user
  def email
    auth.dig("info", "email").downcase
  end

  # @return [String] Unique identifier for the user
  def user_id
    auth["uid"]
  end

  # DSI: OmniAuth organisation scope disabled
  # @return [String] Organisation chosen at authentication
  # def org_id
  #   auth.dig("extra", "raw_info", "organisation", "id")
  # end

  # DSI: RBAC not yet implemented
  # @return [Array] User's associated roles from DSI API
  def roles
    #   client.roles(user_id: user_id, org_id: org_id)
    # rescue ::Dsi::Client::ApiError
    []
  end

  # @return [Array] User's affiliated organisations from DSI API
  def orgs
    @orgs ||= begin
      client.orgs(user_id:)
    rescue ::Dsi::Client::ApiError
      []
    end
  end

  def tracking_base_properties = { dsi_uid: user_id, org_ids: }

  def org_ids = orgs.pluck("id").join(",")
end
