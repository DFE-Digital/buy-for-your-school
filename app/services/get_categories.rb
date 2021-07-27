# Fetch categories from Contentful and upsert into database

class GetCategories
  class CategoriesNotFound < StandardError; end

  # @param contentful_connector [ContentfulConnector] Contentful API wrapper
  #
  def initialize(contentful_connector: ContentfulConnector.new)
    @contentful_connector = contentful_connector
  end

  # @return [Array<Contentful::Entry>]
  def call
    categories = @contentful_connector.by_type("category")
  end

  private

  # todo add rollbar logging

end
