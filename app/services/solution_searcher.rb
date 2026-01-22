require "opensearch/transport"

class SolutionSearcher
  attr_reader :query, :client

  INDEX = "solution-data".freeze

  def initialize(query:)
    @client = SearchClient.instance
    @query = query
  end

  def search
    results = client.search(index: INDEX, body: search_body)["hits"]["hits"]
    return [] if results.empty?

    results.map { Solution.rehydrate_from_search(it["_source"]) }
      .select(&:presentable?)
  end

private

  def search_body
    @search_body ||= {
      query: {
        multi_match: {
          query: query,
          fields: %w[title description summary slug provider_reference],
        },
      },
    }
  end
end
