# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Validate and persist new users and update their DSI details
# Combine auth identity, roles and organisation data from DSI OIDC and API
#
class CreateUser
  extend Dry::Initializer

  # @!attribute [r] auth
  # @return [Hash] OmniAuth response
  option :auth, Types::Hash

  # @!attribute [r] client
  # @return [Dsi::Client] DfE Sign In API (defaults to new instance)
  option :client, default: proc { ::Dsi::Client.new }

  # Create or Update the User and report to Rollbar
  #
  # @return [User, Symbol]
  def call
    return :invalid unless user_id

    if current_user
      update_user!
      Rollbar.info "Updated account for #{user_id}"
      current_user
    elsif supported? || internal?
      create_user!
      Rollbar.info "Created account for #{user_id}"
      current_user
    elsif orgs.none?
      Rollbar.info "User #{user_id} is not in a supported organisation"
      :no_organisation
    else
      Rollbar.info "User #{user_id} is not in a supported organisation"
      :unsupported
    end
  end

private

  # @return [Array<Integer>] the current user's org types
  def establishment_types
    orgs.map { |org| org.dig("type", "id").to_i }
  end

  # @return [Boolean] user is affiliated to a "supported establishment"
  def supported?
    ORG_TYPE_IDS.any? { |id| establishment_types.include?(id) }
  end

  # @return [Boolean] user is a GHBFS or ProcOps team member
  def internal?
    orgs.any? { |org| org["name"] == ENV["PROC_OPS_TEAM"] }
  end

  # @return [User, nil]
  def current_user
    User.find_by(dfe_sign_in_uid: user_id)
  end

  # @return [User]
  def update_user!
    current_user.update!(
      email: email,
      first_name: first_name,
      last_name: last_name,
      orgs: orgs,
      roles: roles,
    )
  end

  # @return [User]
  def create_user!
    User.create!(
      dfe_sign_in_uid: user_id,
      email: email,
      full_name: full_name,
      first_name: first_name,
      last_name: last_name,
      orgs: orgs,
      roles: roles,
    )
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
    auth.dig("info", "email")
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
    #   Rollbar.info "User #{user_id} has no roles"
    []
  end

  # @return [Array] User's affliated organisations from DSI API
  def orgs
    client.orgs(user_id: user_id)
  rescue ::Dsi::Client::ApiError
    Rollbar.info "User #{user_id} has no organisation"
    []
  end
end
