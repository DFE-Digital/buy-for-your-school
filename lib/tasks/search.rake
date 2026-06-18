namespace :search do
  desc "Syncs Contentful data to search index"
  task index: :environment do
    puts "Starting Contentful to search sync..."

    # Create the index if it doesn't exist
    create_index("solution-data")
    entries = Solution.all

    # Prepare the bulk indexing actions
    bulk_actions = entries.map do |entry|
      unless entry.primary_category.nil?
        primary_category = {
          id: entry.primary_category.id,
          title: entry.primary_category.title,
          slug: entry.primary_category.slug,
        }
      end
      {
        index: {
          _index: "solution-data",
          _id: entry.id,
          data: {
            id: entry.id,
            title: entry.title,
            description: entry.description,
            summary: entry.summary,
            slug: entry.slug,
            provider_reference: entry.provider_reference,
            primary_category:,
          },
        },
      }
    end

    # Perform the bulk indexing
    SearchClient.instance.bulk(body: bulk_actions)
    puts "Successfully indexed #{entries.size} entries into search index."
  end

  desc "Deletes all documents from the search index"
  task clear: :environment do
    index_name = "solution-data"

    unless SearchClient.instance.indices.exists?(index: index_name)
      puts "Search index #{index_name} does not exist."
      next
    end

    puts "Clearing search index #{index_name}..."
    response = SearchClient.instance.delete_by_query(
      index: index_name,
      body: {
        query: {
          match_all: {},
        },
      },
      refresh: true,
    )
    puts "Deleted #{response.fetch('deleted', 0)} documents from search index #{index_name}."
  end
end

# Create the index and its mapping
# rubocop:disable Rails/SaveBang
def create_index(index_name)
  return if SearchClient.instance.indices.exists?(index: index_name)

  SearchClient.instance.indices.create(
    index: index_name,
    body: {
      settings: { number_of_shards: 1, number_of_replicas: 0 },
      mappings: {
        properties: {
          id: { type: "keyword" },
          title: { type: "text", analyzer: "english" },
          description: { type: "text", analyzer: "english" },
          summary: { type: "text", analyzer: "english" },
          slug: { type: "keyword" },
          provider_reference: { type: "keyword" },
        },
      },
    },
  )
end
# rubocop:enable Rails/SaveBang
