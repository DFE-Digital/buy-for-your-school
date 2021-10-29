# frozen_string_literal: true

require "jwt"
require "dry-initializer"
require "dsi/user"

module Dsi
  class Client
    class ApiError < StandardError; end

    extend Dry::Initializer

    option :service,      default: proc { ENV["DFE_SIGN_IN_IDENTIFIER"] }
    option :api_endpoint, default: proc { GetDsiUrl.new(domain: "api").call }
    option :api_secret,   default: proc { ENV["DFE_SIGN_IN_API_SECRET"] }

    # @return [String]
    #
    def jwt(validity: 60)
      expires_at = (Time.zone.now.getlocal + validity).to_i
      payload = { iss: service, exp: expires_at, aud: "signin.education.gov.uk" }
      JWT.encode(payload, api_secret, "HS256")
    end

    # @return [Array<Dsi::User>]
    #
    def users
      get_users.map { |user| Dsi::User.new(user: user) }
    end

    # Get user access to service
    #
    # [{
    #   "id": "role-id",
    #   "name": "The name of the role",
    #   "code": "The code of the role",
    #   "numericId": "9999",
    #   "status": {
    #     "id": 1
    #   }
    # }]
    #
    # https://github.com/DFE-Digital/login.dfe.public-api#get-user-access-to-service
    #
    def roles(user_id:, org_id:)
      uri = api_uri("/services/#{service}/organisations/#{org_id}/users/#{user_id}")
      body = get(uri)
      body["roles"].map { |r| r["code"] }
    end

    # [{
    #   "id": "23F20E54-79EA-4146-8E39-18197576F023",
    #   "name": "Department for Education",
    #   "category": {
    #     "id": "002",
    #     "name": "Local Authority"
    #   },
    #   "urn": nil,
    #   "uid": nil,
    #   "ukprn": nil,
    #   "establishmentNumber": "001",
    #   "status": {
    #     "id": 1,
    #     "name": "Open"
    #   },
    #   "closedOn": nil,
    #   "address": nil,
    #   "telephone": nil,
    #   "statutoryLowAge": nil,
    #   "statutoryHighAge": nil,
    #   "legacyId": "1031237",
    #   "companyRegistrationNumber": nil
    # }]
    #
    #
    # https://github.com/DFE-Digital/login.dfe.public-api#get-organisations-for-user
    #
    def orgs(user_id:)
      uri = api_uri("/users/#{user_id}/organisations")
      get(uri)
    end

  private

    # @example
    #   {
    #     "success": false,
    #     "message": "jwt expired" / "invalid signature"
    #   }
    #
    # @param uri [URI]
    #
    # @return [Array, Hash]
    #
    def get(uri)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "bearer #{jwt}"
      request["Content-Type"] = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      raise ApiError, "#{response.code}: #{response.body}" unless response.code.eql?("200")

      JSON.parse(response.body)
    end

    # GET https://environment-url/users?page=1&pageSize=25
    # {
    #   "users": [
    #       ...
    #   ],
    #   "numberOfRecords": 1,
    #   "page": 1,
    #   "numberOfPages": 1
    # }
    #
    # @see https://github.com/DFE-Digital/login.dfe.public-api#service-users
    #
    # @return [Array]
    #
    def get_users
      uri = api_uri("/users")
      body = get(uri)
      page_number = 2
      users = body["users"]

      while page_number <= body["numberOfPages"]
        uri.query = "page=#{page_number}"
        page = get(uri)
        users.concat(page["users"])
        page_number += 1
      end

      users
    end

    # TODO: service now request required?
    #
    # Approvers for organisations
    # https://github.com/DFE-Digital/login.dfe.public-api#approvers-for-organisations
    #
    # def get_approvers
    #   uri = api_uri("/users/approvers")
    #   get(uri)
    # end

    # @return [URI::HTTPS]
    #
    def api_uri(path)
      URI.join(api_endpoint, path)
    end

    # TODO: benchmark performance for http clients
    #
    # @see https://rubydoc.info/gems/httpclient/HTTPClient
    #
    # def http_client
    #   client = HTTPClient.new
    #   headers = [
    #     ["Authorization", "bearer #{jwt}"],
    #     ["Content-Type", "application/json"]
    #   ]
    #   response = client.get(uri, headers, follow_redirect: true)
    # end
  end
end
