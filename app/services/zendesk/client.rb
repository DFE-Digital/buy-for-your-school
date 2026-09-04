# frozen_string_literal: true

require "digest"
require "json"
require "net/http"
require "uri"

module Zendesk
  class Client
    TOKEN_CACHE_EXPIRY = 20.minutes
    TOKEN_EXPIRY = 30.minutes.to_i
    DEFAULT_SCOPE = "account_settings:read read write"

    Error = Class.new(StandardError)
    AuthenticationError = Class.new(Error)

    def initialize(
      subdomain: ENV["ZENDESK_SUBDOMAIN"],
      app_id: ENV["ZENDESK_APP_ID"],
      app_secret_key: ENV["ZENDESK_APP_SECRET_KEY"],
      brand_id: ENV["ZENDESK_BRAND_ID"],
      scope: ENV["ZENDESK_SCOPE"].presence || DEFAULT_SCOPE
    )
      @subdomain = subdomain&.delete_suffix(".")
      @app_id = app_id
      @app_secret_key = app_secret_key
      @brand_id = brand_id
      @scope = scope
    end

    def ticket_form(ticket_form_id:)
      get("/api/v2/ticket_forms/#{ticket_form_id}").fetch("ticket_form")
    end

    def ticket_forms
      get("/api/v2/ticket_forms").fetch("ticket_forms")
    end

    def ticket_fields(ids:)
      return [] if ids.empty?

      get("/api/v2/ticket_fields/show_many", ids: ids.join(",")).fetch("ticket_fields")
    end

    def ticket_form_fields(ticket_form_id:)
      form = ticket_form(ticket_form_id:)

      {
        "ticket_form" => form,
        "ticket_fields" => ticket_fields(ids: form.fetch("ticket_field_ids", [])),
      }
    end

    def create_ticket(subject:, comment:, ticket_form_id:, custom_fields: [], **attributes)
      ticket = attributes.merge(
        subject:,
        comment: { body: comment },
        brand_id:,
        ticket_form_id:,
        custom_fields:,
      )

      post("/api/v2/tickets", body: { ticket: }).fetch("ticket").fetch("id")
    end

  private

    attr_reader :app_id, :app_secret_key, :brand_id, :scope, :subdomain

    def access_token
      Rails.cache.fetch(token_cache_key, expires_in: TOKEN_CACHE_EXPIRY) do
        request_access_token
      end
    end

    def request_access_token
      response = request(
        uri: URI("#{base_url}/oauth/tokens"),
        request_class: Net::HTTP::Post,
        body: {
          grant_type: "client_credentials",
          client_id: app_id,
          client_secret: app_secret_key,
          scope:,
          expires_in: TOKEN_EXPIRY,
        },
        authorization: false,
      )

      response.fetch("access_token")
    rescue KeyError => e
      raise AuthenticationError, "Zendesk OAuth response did not contain an access token: #{e.message}"
    end

    def get(path, query = {})
      request(
        uri: build_uri(path, query),
        request_class: Net::HTTP::Get,
      )
    end

    def post(path, body:)
      request(
        uri: build_uri(path),
        request_class: Net::HTTP::Post,
        body:,
      )
    end

    def request(uri:, request_class:, body: nil, authorization: true)
      request = request_class.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{access_token}" if authorization
      request.body = JSON.generate(body) if body

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      parsed_response = response.body.present? ? JSON.parse(response.body) : {}
      return parsed_response if response.is_a?(Net::HTTPSuccess)

      error_class = authorization ? Error : AuthenticationError
      raise error_class, "Zendesk request failed with #{response.code}: #{parsed_response}"
    rescue JSON::ParserError => e
      raise Error, "Zendesk returned invalid JSON: #{e.message}"
    end

    def build_uri(path, query = {})
      uri = URI("#{base_url}#{path}")
      uri.query = URI.encode_www_form(query) if query.present?
      uri
    end

    def base_url
      "https://#{subdomain}.zendesk.com"
    end

    def token_cache_key
      scope_key = Digest::SHA256.hexdigest(scope)
      "zendesk/oauth/access_token/#{subdomain}/#{app_id}/#{scope_key}"
    end
  end
end
