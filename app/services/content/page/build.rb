# Persist Page entries from Contentful
#
class Content::Page::Build
  extend Dry::Initializer

  # @!attribute [r] contentful_page
  #   @return [Contentful::Entry] Contentful "Page" entity
  #   @api private
  option :contentful_page, Types.Instance(Contentful::Entry), reader: :private

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
      returning: %w[title contentful_id slug],
    )

    Rollbar.info("Built Contentful page", **page.first) if page
    Page.find_by(contentful_id: contentful_page.id)
  end
end
