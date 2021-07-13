# Fetch and cache Contentful sections for the category
#
class GetSectionsFromCategory
  # @return [Contentful::Entry]
  attr_accessor :category

  # @param category [Contentful::Entry]
  def initialize(category:)
    self.category = category
  end

  # @return [Array<Contentful::Entry>]
  def call
    category.sections.map { |section| GetEntry.new(entry_id: section.id).call }
  end
end
