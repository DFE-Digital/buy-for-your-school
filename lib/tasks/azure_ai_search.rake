namespace :azure_ai_search do
  desc "Creates the Azure AI Search solution index"
  task create_index: :environment do
    index_name = AzureAiSearch::SolutionIndexSchema::INDEX
    client = AzureAiSearch::Client.new

    if client.index_exists?(index_name:)
      puts "Azure AI Search index #{index_name} already exists."
      next
    end

    puts "Creating Azure AI Search index #{index_name}..."
    client.create_index(body: AzureAiSearch::SolutionIndexSchema.to_h)
    puts "Created Azure AI Search index #{index_name}."
  end

  desc "Syncs Contentful solutions to Azure AI Search"
  task index: :environment do
    puts "Starting Contentful to Azure AI Search sync..."

    index_name = AzureAiSearch::SolutionIndexer::INDEX
    solutions = Solution.all
    client = AzureAiSearch::Client.new
    responses = AzureAiSearch::SolutionIndexer.new(client:).index_all(solutions)
    indexed_count = responses.sum { |response| Array(response["value"]).count { |result| result["status"] == true } }

    puts "Successfully indexed #{indexed_count} of #{solutions.size} solutions into Azure AI Search."
    puts "Azure AI Search document count for #{index_name}: #{client.document_count(index_name:)}"
  end

  desc "Counts documents in the Azure AI Search solution index"
  task count: :environment do
    index_name = AzureAiSearch::SolutionIndexer::INDEX

    puts "Azure AI Search document count for #{index_name}: #{AzureAiSearch::Client.new.document_count(index_name:)}"
  end

  desc "Deletes all documents from the Azure AI Search solution index"
  task clear: :environment do
    index_name = AzureAiSearch::SolutionIndexer::INDEX
    client = AzureAiSearch::Client.new

    puts "Clearing Azure AI Search index #{index_name}..."

    document_ids = client.search(
      index_name:,
      body: {
        search: "*",
        select: "id",
        top: 1000,
      },
    )["value"].map { |document| document["id"] }

    if document_ids.empty?
      puts "Azure AI Search index #{index_name} is already empty."
      next
    end

    responses = document_ids.each_slice(AzureAiSearch::SolutionIndexer::BATCH_SIZE).map do |ids|
      client.index_documents(
        index_name:,
        documents: ids.map { |id| AzureAiSearch::SolutionDocument.delete(id) },
      )
    end
    deleted_count = responses.sum { |response| Array(response["value"]).count { |result| result["status"] == true } }

    puts "Deleted #{deleted_count} documents from Azure AI Search index #{index_name}."
    puts "Azure AI Search document count for #{index_name}: #{client.document_count(index_name:)}"
  end
end
