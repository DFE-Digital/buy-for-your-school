# Fetch and cache Contentful sections for the category
#
class GetSectionsFromCategory
  # @param category [Contentful::Entry]
  # @param client [Content::Client]
  #
  def initialize(category:, client: Content::Client.new)
    @category = category
    @client = client
  end

  # @return [Array<Contentful::Entry>]
  def call
    @category.sections.map do |section|
      GetEntry.new(entry_id: section.id, client: @client).call
    end
  end
end
