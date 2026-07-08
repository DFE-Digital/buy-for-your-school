module AzureAiSearch
  class SolutionIndexer
    INDEX = ENV.fetch("AZURE_AI_SEARCH_INDEX_NAME", "solution-data")
    BATCH_SIZE = 100

    def initialize(client: Client.new)
      @client = client
    end

    def index_all(solutions = Solution.all)
      responses = solutions.each_slice(BATCH_SIZE).map do |batch|
        documents = batch.filter_map do |solution|
          SolutionDocument.from_solution(solution) if solution.presentable?
        end
        next if documents.empty?

        client.index_documents(index_name: INDEX, documents:)
      end

      responses.compact
    end

    def index_document(id)
      solution = Solution.find_by_id!(id)
      return false unless solution&.presentable?

      response = client.index_documents(
        index_name: INDEX,
        documents: [SolutionDocument.from_solution(solution)],
      )

      successful_response?(response)
    end

    def delete_document(id)
      response = client.index_documents(
        index_name: INDEX,
        documents: [SolutionDocument.delete(id)],
      )

      successful_response?(response)
    end

  private

    attr_reader :client

    def successful_response?(response)
      Array(response["value"]).all? { |result| result["status"] == true }
    end
  end
end
