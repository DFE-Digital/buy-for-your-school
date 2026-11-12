module AzureAiSearch
  class ContentfulIndexer
    INDEX = ContentfulIndexSchema::INDEX
    BATCH_SIZE = 100

    def initialize(client: Client.new)
      @client = client
    end

    def index_all(records = all_records)
      records.each_slice(BATCH_SIZE).filter_map do |batch|
        documents = batch.filter_map { |record| ContentfulDocument.from_record(record) }
        client.index_documents(index_name: INDEX, documents:) if documents.any?
      end
    end

    def sync_all(records = all_records)
      documents = records.filter_map { |record| ContentfulDocument.from_record(record) }
      current_ids = documents.map { |document| document[:id] }
      stale_ids = existing_document_ids - current_ids

      {
        deleted: delete_documents(stale_ids),
        indexed: index_documents(documents),
      }
    end

    def index_document(id, content_type:)
      record = find_record!(id, content_type)
      document = ContentfulDocument.from_record(record)
      return false unless document

      response = client.index_documents(index_name: INDEX, documents: [document])
      successful_response?(response)
    end

    def delete_document(id, content_type:)
      document_id = ContentfulDocument.document_id(id, content_type)
      response = client.index_documents(index_name: INDEX, documents: [ContentfulDocument.delete(document_id)])
      successful_response?(response)
    end

    def delete_documents(ids)
      ids.each_slice(BATCH_SIZE).map do |batch|
        client.index_documents(index_name: INDEX, documents: batch.map { |id| ContentfulDocument.delete(id) })
      end
    end

    def existing_document_ids
      client.search(index_name: INDEX, body: { search: "*", select: "id", top: 1000 })["value"].map { |document| document["id"] }
    end

  private

    attr_reader :client

    def all_records
      Solution.all + FABS::Category.all + FABS::Page.all
    end

    def find_record!(id, content_type)
      case content_type.to_s
      when "solution"
        Solution.find_by_id!(id)
      when "category"
        FABS::Category.find_by_id!(id)
      when "page"
        FABS::Page.find_by_id!(id)
      else
        raise ArgumentError, "Unsupported Contentful content type: #{content_type}"
      end
    end

    def index_documents(documents)
      documents.each_slice(BATCH_SIZE).filter_map do |batch|
        client.index_documents(index_name: INDEX, documents: batch) if batch.any?
      end
    end

    def successful_response?(response)
      Array(response["value"]).all? { |result| result["status"] == true }
    end
  end
end
