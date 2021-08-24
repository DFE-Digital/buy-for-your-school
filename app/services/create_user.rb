# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Combine auth identity, roles and organisation data from DSI OIDC and API
#
# TODO: rename CreateUser to CreateProfile
class CreateUser
  extend Dry::Initializer

  option :auth, Types::Hash
  option :client, default: proc { ::Dsi::Client.new }

  # @return [User] TODO: separate concerns of User and Profile
  #
  def call
    return false unless user_id

    User.find_or_create_by!(dfe_sign_in_uid: user_id) do |user|
      user.email      = email
      user.full_name  = full_name
      user.first_name = first_name
      user.last_name  = last_name
      # DSI: newly added organisations will be missing for existing users
      user.orgs = orgs
      # DSI: newly added roles will not be added unless we refresh
      user.roles = roles
      # Rails.logger.info "Created account for #{email}"
    end
  end

private

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
