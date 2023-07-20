# Persist Page entries from Contentful
#
class Content::Page::Build
  extend Dry::Initializer
  include InsightsTrackable

  # @!attribute [r] contentful_page
  #   @return [Contentful::Entry] Contentful "Page" entity
  #   @api private
  option :contentful_page, Types.Instance(Contentful::Entry), reader: :private

  # @return [Page]
  def call
    page = ::Page.upsert(
      {
        title: contentful_page.fields[:title],
        body: contentful_page.fields[:body],
        contentful_id: contentful_page.id,
        slug: contentful_page.fields[:slug],
        sidebar: contentful_page.fields[:sidebar],
        breadcrumbs: contentful_page.fields[:breadcrumbs],
      },
      unique_by: :contentful_id,
      returning: %w[title contentful_id slug],
    )

    track_event("Contentful/Page/Built", slug: contentful_page.fields[:slug]) if page
    ::Page.find_by(contentful_id: contentful_page.id)
  end
end
