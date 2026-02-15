require "opensearch/transport"

class SolutionIndexer
  attr_reader :id, :client

  INDEX = "solution-data".freeze

  def initialize(id:)
    @client = SearchClient.instance
    @id = id
  end

  def index_document
    return false if entry.nil?

    response = client.index(index: INDEX, id:, body:)

    return true if index_created?(response["result"])

    false
  end

  def delete_document
    response = client.delete(index: INDEX, id:)
    return true if index_deleted?(response["result"])

    false
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    true
  end

  def find_document
    client.get(
      index: "solution-data",
      id:,
    )
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    nil
  end

private

  def index_created?(result)
    %w[created updated].include?(result)
  end

  def index_deleted?(result)
    result == "deleted"
  end

  def entry
    @entry ||= Solution.find_by_id!(id)
  end

  def body
    {
      id: entry.id,
      title: entry.title,
      description: entry.description,
      summary: entry.summary,
      slug: entry.slug,
      provider_reference: entry.provider_reference,
      primary_category:,
    }
  end

  def primary_category
    {
      id: entry.primary_category.id,
      title: entry.primary_category.title,
      slug: entry.primary_category.slug,
    }
  end
end
