# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Persist new users and update their name when DSI details are edited
# Combine auth identity, roles and organisation data from DSI OIDC and API
#
class CreateUser
  extend Dry::Initializer

  option :auth, Types::Hash
  option :client, default: proc { ::Dsi::Client.new }

  # @return [User, false]
  def call
    return false unless user_id

    if current_user
      current_user.update!(first_name: first_name, last_name: last_name, orgs: orgs)
      Rollbar.info "Updated account for #{email}"
      current_user
    else
      new_user = create_user!
      Rollbar.info "Created account for #{email}"
      new_user
    end
  end

private

  # @return [User, nil]
  def current_user
    User.find_by(dfe_sign_in_uid: user_id)
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

  # Unique identifier for the user
  #
  # @return [String]
  def email
    auth.dig("info", "email")
  end

  # Unique identifier for the user
  #
  # @return [String]
  def user_id
    auth["uid"]
  end

  # Organisation chosen at authentication
  #
  # @return [String]
  def org_id
    auth.dig("extra", "raw_info", "organisation", "id")
  end

  # User's associated roles from DSI API
  #
  # @return [Array]
  def roles
    client.roles(user_id: user_id, org_id: org_id)
  rescue ::Dsi::Client::ApiError
    Rollbar.info "User #{user_id} has no roles"
  end

  # User's affliated organisations from DSI API
  #
  # @return [Array]
  def orgs
    client.orgs(user_id: user_id)
  rescue ::Dsi::Client::ApiError
    Rollbar.info "User #{user_id} has no organisation"
  end
end
