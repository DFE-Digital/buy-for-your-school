require "dry-initializer"

# Persits Page entries from Contentful
#
class Content::Page::Build
  extend Dry::Initializer

  # @!attribute [r] contentful_page
  # @return [Contentful::Entry]
  option :contentful_page

  # @return [Page]
  def call
    page = Page.upsert(
      {
        title: contentful_page.title,
        body: contentful_page.body,
        contentful_id: contentful_page.id,
        slug: contentful_page.slug,
        sidebar: contentful_page.sidebar,
      },
      unique_by: :contentful_id,
      returning: %w[title contentful_id slug body sidebar],
    )

    Rollbar.info("Built Contentful page", **page.first) if page

    Page.find_by(contentful_id: contentful_page.id)
  end
end
