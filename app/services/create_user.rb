# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Persist new users and update their DSI details
# Combine auth identity, roles and organisation data from DSI OIDC and API
#
class CreateUser
  class NoOrganisationError < StandardError; end

  class UnsupportedOrganisationError < StandardError; end

  extend Dry::Initializer

  # OmniAuth response
  option :auth, Types::Hash

  # DfE Sign In API
  option :client, default: proc { ::Dsi::Client.new }

  # Create or Update the User and report to Rollbar
  #
  # @return [User, false]
  def call
    # binding.pry
    return false unless user_id

    if current_user
      update_user!
      Rollbar.info "Updated account for #{user_id}"
    elsif supported_establishment?
      create_user!
      Rollbar.info "Created account for #{user_id}"
    else
      Rollbar.info "User #{user_id} belongs to an unsupported organisation"
      raise UnsupportedOrganisationError
    end

    current_user
  end

private

  # @return [Boolean]
  def supported_establishment?
    # check all organisations or caseworker
    orgs.any? { |org| ORG_TYPE_IDS.include?(org.dig("type", "id")&.to_i) } || is_caseworker?
  end

  # @return [String, nil]
  def current_org_type_id
    orgs.find { |org| org["id"].eql?(org_id) }.dig("type", "id")
  end

  # @return [Boolean]
  def is_caseworker?
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
    raise NoOrganisationError
  end
end
