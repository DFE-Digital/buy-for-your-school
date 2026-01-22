class SearchClient
  include Singleton
  extend Forwardable

  def_delegators :@client, :get, :delete, :index, :indices, :bulk, :search

  def initialize
    @client = build_client
  end

private

  def build_client
    url = %w[OPENSEARCH_URL BONSAI_URL]
      .map { |key| ENV[key] }.find { |url| url }
    return DummyClient.new unless url

    ::OpenSearch::Client.new(url: url)
  end

  class DummyClient
    NotConfigured = Class.new(StandardError)

    def get(*, **, &) = raise_not_configured
    def delete(*, **, &) = raise_not_configured
    def index(*, **, &) = raise_not_configured
    def indices(*, **, &) = raise_not_configured
    def bulk(*, **, &) = raise_not_configured
    def search(*, **, &) = raise_not_configured

  private

    def raise_not_configured(*, **)
      raise NotConfigured, "Search client is not configured"
    end
  end
end
