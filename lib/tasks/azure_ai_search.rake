namespace :azure_ai_search do
  desc "Creates the Azure AI Search Contentful index"
  task create_index: :environment do
    index_name = AzureAiSearch::ContentfulIndexSchema::INDEX
    client = AzureAiSearch::Client.new

    if client.index_exists?(index_name:)
      puts "Azure AI Search index #{index_name} already exists."
      next
    end

    puts "Creating Azure AI Search index #{index_name}..."
    client.create_index(body: AzureAiSearch::ContentfulIndexSchema.to_h)
    puts "Created Azure AI Search index #{index_name}."
  end

  desc "Deletes the Azure AI Search Contentful index"
  task delete_index: :environment do
    index_name = AzureAiSearch::ContentfulIndexSchema::INDEX
    client = AzureAiSearch::Client.new

    unless client.index_exists?(index_name:)
      puts "Azure AI Search index #{index_name} does not exist."
      next
    end

    puts "Deleting Azure AI Search index #{index_name}..."
    client.delete_index(index_name:)
    puts "Deleted Azure AI Search index #{index_name}."
  end

  desc "Syncs Contentful solutions, categories and pages to Azure AI Search"
  task index: :environment do
    puts "Starting Contentful to Azure AI Search sync..."

    index_name = AzureAiSearch::ContentfulIndexer::INDEX
    records = Solution.all + FABS::Category.all + FABS::Page.all
    client = AzureAiSearch::Client.new
    sync_result = AzureAiSearch::ContentfulIndexer.new(client:).sync_all(records)
    indexable_count = records.count { |record| AzureAiSearch::ContentfulDocument.from_record(record).present? }
    indexed_count = Array(sync_result[:indexed]).sum do |response|
      Array(response["value"]).count { |result| result["status"] == true }
    end
    deleted_count = Array(sync_result[:deleted]).sum do |response|
      Array(response["value"]).count { |result| result["status"] == true }
    end

    puts "Successfully indexed #{indexed_count} of #{indexable_count} Contentful records into Azure AI Search."
    puts "Successfully deleted #{deleted_count} stale documents from Azure AI Search."
    puts "Azure AI Search document count for #{index_name}: #{client.document_count(index_name:)}"
  end

  desc "Counts documents in the Azure AI Search Contentful index"
  task count: :environment do
    index_name = AzureAiSearch::ContentfulIndexer::INDEX

    puts "Azure AI Search document count for #{index_name}: #{AzureAiSearch::Client.new.document_count(index_name:)}"
  end

  desc "Deletes all documents from the Azure AI Search Contentful index"
  task clear: :environment do
    index_name = AzureAiSearch::ContentfulIndexer::INDEX
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

    responses = document_ids.each_slice(AzureAiSearch::ContentfulIndexer::BATCH_SIZE).map do |ids|
      client.index_documents(
        index_name:,
        documents: ids.map { |id| AzureAiSearch::ContentfulDocument.delete(id) },
      )
    end
    deleted_count = responses.sum { |response| Array(response["value"]).count { |result| result["status"] == true } }

    puts "Deleted #{deleted_count} documents from Azure AI Search index #{index_name}."
    puts "Azure AI Search document count for #{index_name}: #{client.document_count(index_name:)}"
  end
end
