module AzureAiSearch
  class SolutionSearcher
    INDEX = ENV.fetch("AZURE_AI_SEARCH_INDEX_NAME", "solution-data")
    SEMANTIC_CONFIGURATION = ENV.fetch("AZURE_AI_SEARCH_SEMANTIC_CONFIGURATION", "solutions-v1")

    def initialize(query:, client: Client.new)
      @query = query
      @client = client
    end

    def search
      response = client.search(index_name: INDEX, body: search_body)
      Array(response["value"]).filter_map { |result|
        Solution.rehydrate_from_search(result.except(*metadata_keys))
      }.select(&:presentable?)
    end

  private

    attr_reader :query, :client

    def search_body
      {
        search: query,
        queryType: query_type,
        semanticConfiguration: semantic_search? ? SEMANTIC_CONFIGURATION : nil,
        semanticErrorHandling: semantic_search? ? "partial" : nil,
        captions: semantic_search? ? "extractive|highlight-true" : nil,
        top: ENV.fetch("AZURE_AI_SEARCH_TOP", "10").to_i,
        select: "id,title,description,summary,slug,provider_reference,primary_category",
      }.compact
    end

    def query_type
      ENV.fetch("AZURE_AI_SEARCH_QUERY_TYPE", "simple")
    end

    def semantic_search?
      query_type == "semantic"
    end

    def metadata_keys
      @metadata_keys ||= %w[
        @search.score
        @search.rerankerScore
        @search.captions
        @search.highlights
      ]
    end
  end
end
