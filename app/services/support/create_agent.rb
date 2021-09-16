# frozen_string_literal: true

require "dry-initializer"
require "dsi/client"
require "types"

# Combine auth identity, roles and organisation data from DSI OIDC and API

module Support
  class CreateAgent
    extend Dry::Initializer

    option :auth, Types::Hash
    # option :client, default: proc { ::Dsi::Client.new }

    # @return [Agent]
    #
    def call
      return false unless agent_id

      Agent.find_or_create_by!(dfe_support_sign_in_uid: agent_id) do |agent|
        agent.email = email
        agent.full_name = full_name
        agent.first_name = first_name
        agent.last_name = last_name

        # TODO: CLEAN THIS UP
        # # DSI: newly added organisations will be missing for existing agents
        # agent.orgs = orgs
        # # DSI: newly added roles will not be added unless we refresh
        # agent.roles = roles
        # # Rails.logger.info "Created account for #{email}"
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

    # Unique identifier for the agent
    #
    # @return [String]
    def email
      auth.dig("info", "email")
    end

    # Unique identifier for the agent
    #
    # @return [String]
    def agent_id
      auth["uid"]
    end

    # Organisation chosen at authentication
    #
    # @return [String]
    def org_id
      auth.dig("extra", "raw_info", "organisation", "id")
    end

    # # Agent's associated roles from DSI API
    # #
    # # @return [Array]
    # def roles
    #   client.roles(agent_id: agent_id, org_id: org_id)
    # rescue ::Dsi::Client::ApiError
    #   Rollbar.info "Agent #{agent_id} has no roles"
    # end
    #
    # # Agent's affliated organisations from DSI API
    # #
    # # @return [Array]
    # def orgs
    #   client.orgs(agent_id: agent_id)
    # rescue ::Dsi::Client::ApiError
    #   Rollbar.info "Agent #{agent_id} has no organisation"
    # end
  end
end