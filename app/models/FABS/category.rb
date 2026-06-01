require "ostruct"

module FABS
  class Category
    include ActiveModel::Model
    include HasRelatedContent

    CONTENT_TYPE = "category".freeze
    SUMMARY_SELECT = "sys.id,fields.title,fields.description,fields.slug,fields.banner".freeze

    attr_reader :id, :title, :description, :slug, :subcategories, :banner,
                :intro_header, :intro_text, :intro_cta, :how_to_buy, :guidance_links, :request_for_help, :dfe_highlights

    def initialize(entry)
      @id = entry.id
      @title = entry.fields[:title]
      @description = entry.fields[:description]
      @slug = entry.fields[:slug]
      @subcategories = entry.fields.fetch(:subcategories, []).map { |subcat| Subcategory.new(subcat) }.sort_by(&:title)
      @banner = entry.fields[:banner] ? Banner.new(entry.fields[:banner]) : nil

      @intro_header = entry.fields[:intro_header]
      @intro_text = entry.fields[:intro_text]
      @intro_cta = entry.fields[:intro_cta]
      @how_to_buy = entry.fields[:how_to_buy]
      @guidance_links = entry.fields.fetch(:guidance_link, []).map { |item| GuidanceLink.new(item) }
      @request_for_help = entry.fields.fetch(:request_for_help, []).map { |item| RelatedContentWithText.new(item) }
      @dfe_highlights = entry.fields.fetch(:offer, []).map { |item| Offer.new(item) }

      super
    end

    def solutions
      Solution.all(category_id: id)
    end

    def self.all
      category_ids = Solution.unique_category_ids
      return [] if category_ids.blank?

      params = {
        content_type: CONTENT_TYPE,
        select: SUMMARY_SELECT,
        order: "fields.title",
        "sys.id[in]" => category_ids.join(","),
        include: 1,
      }

      ContentfulClient.entries(params).map { |entry| new(entry) }
    end

    def self.search(query: "")
      ContentfulClient.entries(
        content_type: CONTENT_TYPE,
        query:,
        select: SUMMARY_SELECT,
        include: 1,
      ).map { |entry| new(entry) }
    end

    def self.rehydrate_from_search(result)
      return nil unless result

      new(OpenStruct.new(
            id: result["id"],
            fields: { title: result["title"], slug: result["slug"] },
          ))
    end

    def to_param
      slug
    end

    def self.find_by_slug!(slug)
      entry = ContentfulClient.entries(
        content_type: CONTENT_TYPE,
        'fields.slug': slug,
        include: 1,
      ).first

      raise ContentfulRecordNotFoundError.new("Category not found", slug:) unless entry

      new(entry)
    end

    def filtered_solutions(subcategory_slugs: nil)
      return solutions if subcategory_slugs.blank?

      solutions.select do |solution|
        solution.subcategories&.any? do |subcat|
          subcategory_slugs.include?(subcat.fields[:slug])
        end
      end
    end
  end
end
