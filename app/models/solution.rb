require "ostruct"

class Solution
  include ActiveModel::Model
  include HasRelatedContent

  CONTENT_TYPE = "solution".freeze

  # Contentful field identifiers
  SYS_ID = "sys.id".freeze
  FIELD_TITLE = "fields.title".freeze
  FIELD_DESCRIPTION = "fields.description".freeze
  FIELD_SUMMARY = "fields.summary".freeze
  FIELD_SLUG = "fields.slug".freeze
  FIELD_PROVIDER_NAME = "fields.provider_name".freeze
  FIELD_PROVIDER_INITIALS = "fields.provider_initials".freeze
  FIELD_BUYING_OPTION_TYPE = "fields.buying_option_type".freeze
  FIELD_PROVIDER_REFERENCE = "fields.provider_reference".freeze
  FIELD_PRIMARY_CATEGORY = "fields.primary_category".freeze

  SELECT_FIELDS = [
    SYS_ID,
    FIELD_TITLE,
    FIELD_DESCRIPTION,
    "fields.expiry",
    "fields.related_content",
    FIELD_SUMMARY,
    FIELD_SLUG,
    "fields.suffix",
    FIELD_PROVIDER_NAME,
    FIELD_PROVIDER_INITIALS,
    "fields.call_to_action",
    "fields.url",
    FIELD_BUYING_OPTION_TYPE,
    FIELD_PROVIDER_REFERENCE,
    FIELD_PRIMARY_CATEGORY,
  ].join(",").freeze

  LIST_SELECT_FIELDS = [
    SYS_ID,
    FIELD_TITLE,
    FIELD_DESCRIPTION,
    "fields.expiry",
    FIELD_SLUG,
    "fields.categories",
    "fields.subcategories",
    "fields.url",
    FIELD_PROVIDER_NAME,
    FIELD_PROVIDER_INITIALS,
    "fields.related_content",
    FIELD_SUMMARY,
    FIELD_BUYING_OPTION_TYPE,
    FIELD_PROVIDER_REFERENCE,
    FIELD_PRIMARY_CATEGORY,
  ].join(",").freeze

  SEARCH_SELECT_FIELDS = [
    SYS_ID,
    FIELD_TITLE,
    FIELD_SUMMARY,
    FIELD_DESCRIPTION,
    FIELD_SLUG,
    FIELD_PROVIDER_NAME,
    FIELD_BUYING_OPTION_TYPE,
    FIELD_PROVIDER_INITIALS,
    FIELD_PRIMARY_CATEGORY,
    FIELD_PROVIDER_REFERENCE,
  ].join(",").freeze

  attr_reader :id, :title, :description, :expiry, :summary,
              :slug, :provider_name, :provider_initials, :url,
              :categories, :subcategories, :suffix, :call_to_action,
              :primary_category, :buying_option_type, :provider_reference

  delegate :slug, to: :primary_category, prefix: true, allow_nil: true

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @summary = entry.fields[:summary]
    @description = entry.fields[:description]
    @slug = entry.fields[:slug]
    @provider_name = entry.fields[:provider_name]
    @provider_initials = entry.fields[:provider_initials]
    @url = entry.fields[:url]
    @expiry = entry.fields[:expiry]
    @suffix = entry.fields[:suffix]
    @call_to_action = entry.fields[:call_to_action]
    @categories = entry.fields[:categories]
    @subcategories = entry.fields[:subcategories]
    @primary_category = entry.fields[:primary_category]
    @buying_option_type = entry.fields[:buying_option_type]
    @provider_reference = entry.fields[:provider_reference]
    super
  end

  def self.all(category_id: nil)
    params = {
      content_type: CONTENT_TYPE,
      select: LIST_SELECT_FIELDS,
      order: FIELD_TITLE,
      "fields.categories.sys.id[in]": category_id,
    }.compact
    ContentfulClient.entries(params).map { |entry| new(entry) }
  end

  def self.search(query: "")
    use_opensearch = ENV.fetch("USE_OPENSEARCH", "false")
    if use_opensearch == "true"
      SolutionSearcher.new(query:).search
    else
      ContentfulClient.entries(
        content_type: CONTENT_TYPE,
        query:,
        select: SEARCH_SELECT_FIELDS,
      ).map { |entry| new(entry) }
    end
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: CONTENT_TYPE,
      'fields.slug': slug,
      include: 1,
      select: SELECT_FIELDS,
    ).find { |solution| solution.fields[:slug] == slug }

    raise ContentfulRecordNotFoundError.new("Solution not found", slug:) unless entry

    new(entry)
  end

  def self.find_by_id!(id)
    entry = ContentfulClient.entries(
      content_type: CONTENT_TYPE,
      'sys.id': id,
      include: 1,
      select: SELECT_FIELDS,
    ).find { |solution| solution.sys[:id] == id }

    raise ContentfulRecordNotFoundError.new("Solution not found", id:) unless entry

    new(entry)
  end

  def self.unique_category_ids
    ContentfulClient.entries(
      content_type: CONTENT_TYPE,
      select: "fields.categories",
    ).flat_map { |solution| solution.fields[:categories]&.map(&:id) }.compact.uniq
  end

  def self.rehydrate_from_search(result)
    return nil unless result

    category = FABS::Category.rehydrate_from_search(result["primary_category"])
    fields = result
      .transform_keys(&:to_sym)
      .merge(primary_category: category)

    new(OpenStruct.new(id: result["id"], fields:))
  end

  def ==(other)
    super ||
      other.instance_of?(self.class) && other.id == id
  end

  def as_json(_options = {})
    {
      id:,
      provider: {
        initials: provider_initials,
        title: provider_name,
      },
      cat: {
        title: categories.first&.title,
        ref: categories.first&.slug,
      },
      links: Array(related_content).map do |content|
        {
          text: content.link_text,
          url: content.url,
        }
      end,
      ref: slug,
      title:,
      url:,
      descr: description,
      expiry:,
      body: summary,
      primary_category: {
        title: primary_category&.title,
        ref: primary_category&.slug,
      },
      provider_reference:,
    }
  end

  def presentable?
    title.present? && slug.present? && primary_category
  end
end
