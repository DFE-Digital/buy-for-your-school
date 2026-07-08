require "json"
require "net/http"
require "uri"

module AzureAiSearch
  class Client
    DEFAULT_API_VERSION = "2024-07-01"

    Error = Class.new(StandardError)
    NotFound = Class.new(Error)
    NotConfigured = Class.new(Error)

    def initialize(
      endpoint: ENV["AZURE_AI_SEARCH_ENDPOINT"],
      api_key: ENV["AZURE_AI_SEARCH_API_KEY"],
      api_version: ENV.fetch("AZURE_AI_SEARCH_API_VERSION", DEFAULT_API_VERSION)
    )
      @endpoint = endpoint&.delete_suffix("/")
      @api_key = api_key
      @api_version = api_version
    end

    def search(index_name:, body:)
      post(path: "/indexes('#{index_name}')/docs/search.post.search", body:)
    end

    def index_documents(index_name:, documents:)
      post(path: "/indexes('#{index_name}')/docs/search.index", body: { value: documents })
    end

    def document_count(index_name:)
      get(path: "/indexes('#{index_name}')/docs/$count")
    end

    def create_index(body:)
      post(path: "/indexes", body:)
    end

    def delete_index(index_name:)
      delete(path: "/indexes('#{index_name}')")
    end

    def index_exists?(index_name:)
      get(path: "/indexes('#{index_name}')")
      true
    rescue NotFound
      false
    end

  private

    attr_reader :endpoint, :api_key, :api_version

    def get(path:)
      request(path:, request_class: Net::HTTP::Get)
    end

    def delete(path:)
      request(path:, request_class: Net::HTTP::Delete)
    end

    def post(path:, body:)
      request(path:, request_class: Net::HTTP::Post, body:)
    end

    def request(path:, request_class:, body: nil)
      ensure_configured!

      uri = URI("#{endpoint}#{path}?api-version=#{api_version}")
      request = request_class.new(uri)
      request["Content-Type"] = "application/json"
      request["api-key"] = api_key
      request.body = JSON.generate(body) if body

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      parsed_response = response.body.present? ? JSON.parse(response.body) : {}
      return parsed_response if response.is_a?(Net::HTTPSuccess) || response.code == "207"

      raise NotFound, "Azure AI Search resource was not found: #{parsed_response}" if response.code == "404"

      raise Error, "Azure AI Search request failed with #{response.code}: #{parsed_response}"
    end

    def ensure_configured!
      raise NotConfigured, "AZURE_AI_SEARCH_ENDPOINT is not configured" if endpoint.blank?
      raise NotConfigured, "AZURE_AI_SEARCH_API_KEY is not configured" if api_key.blank?
    end
  end
end
