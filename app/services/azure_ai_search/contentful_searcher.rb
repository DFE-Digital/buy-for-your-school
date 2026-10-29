module AzureAiSearch
  class ContentfulSearcher
    INDEX = ContentfulIndexSchema::INDEX
    SEMANTIC_CONFIGURATION = ContentfulIndexSchema::SEMANTIC_CONFIGURATION
    SELECT_FIELDS = "id,content_type,title,description,slug,primary_category".freeze

    SearchResult = Struct.new(:id, :content_type, :title, :description, :slug, :primary_category, keyword_init: true) do
      def path
        case content_type
        when "solution"
          Rails.application.routes.url_helpers.category_solution_path(
            slug:,
            category_slug: primary_category&.dig("slug"),
          )
        when "category"
          Rails.application.routes.url_helpers.category_path(slug:)
        when "page"
          Rails.application.routes.url_helpers.page_path(slug:).gsub("%2F", "/")
        end
      end
    end

    def initialize(query:, client: Client.new)
      @query = query
      @client = client
    end

    def search
      response = client.search(index_name: INDEX, body: search_body)
      Array(response["value"]).filter_map do |result|
        SearchResult.new(**result.slice(*SELECT_FIELDS.split(",")).transform_keys(&:to_sym))
      end
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
        top: ENV.fetch("AZURE_AI_SEARCH_TOP", "15").to_i,
        select: SELECT_FIELDS,
      }.compact
    end

    def query_type
      ENV.fetch("AZURE_AI_SEARCH_QUERY_TYPE", "simple")
    end

    def semantic_search?
      query_type == "semantic"
    end
  end
end
