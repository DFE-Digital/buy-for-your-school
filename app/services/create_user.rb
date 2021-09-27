# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Persist new users and update their DSI details
# Combine auth identity, roles and organisation data from DSI OIDC and API
#
class CreateUser
  extend Dry::Initializer

  # OmniAuth response
  option :auth, Types::Hash

  # DfE Sign In API
  option :client, default: proc { ::Dsi::Client.new }

  # Create or Update the User and report to Rollbar
  #
  # @return [User, false]
  def call
    return false unless user_id

    if current_user
      update_user!
      Rollbar.info "Updated account for #{email}"
    else
      create_user! if supported_establishment?
      Rollbar.info "Created account for #{email}"
    end

    current_user
  end

private

  # @return [Boolean]
  def supported_establishment?
    # check current organisation
    ORG_TYPE_IDS.include?(current_org_type_id)
    # check all organisations
    # orgs.any? { |org| ORG_TYPE_IDS.include?(org["type"]["id"]) }
  end

  # @return [String]
  def current_org_type_id
    orgs.select { |org| org["id"].eql?(org_id) }["type"]["id"]
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

  # @return [String] Organisation chosen at authentication
  def org_id
    auth.dig("extra", "raw_info", "organisation", "id")
  end

  # @return [Array] User's associated roles from DSI API
  def roles
    client.roles(user_id: user_id, org_id: org_id)
  rescue ::Dsi::Client::ApiError
    Rollbar.info "User #{user_id} has no roles"
  end

  # @return [Array] User's affliated organisations from DSI API
  def orgs
    client.orgs(user_id: user_id)
  rescue ::Dsi::Client::ApiError
    Rollbar.info "User #{user_id} has no organisation"
  end
end
