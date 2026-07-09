require "ostruct"

module FABS
  class Category
    include ActiveModel::Model
    include HasRelatedContent

    CONTENT_TYPE = "category".freeze
    SUMMARY_SELECT = "sys.id,fields.title,fields.description,fields.slug,fields.banner".freeze

    attr_reader :id, :title, :description, :slug, :subcategories, :banner, :get_expert_help

    def initialize(entry)
      @id = entry.id
      @title = entry.fields[:title]
      @description = entry.fields[:description]
      @slug = entry.fields[:slug]
      @subcategories = entry.fields.fetch(:subcategories, []).map { |subcat| Subcategory.new(subcat) }.sort_by(&:title)
      @banner = entry.fields[:banner] ? Banner.new(entry.fields[:banner]) : nil
      @get_expert_help = entry.fields[:get_expert_help] ? GetExpertHelp.new(entry.fields[:get_expert_help]) : nil
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

    def filtered_solutions(subcategory_slugs: nil, ways_to_buy_slugs: nil)
      return solutions if subcategory_slugs.blank? && ways_to_buy_slugs.blank?

      solutions.select do |solution|
        subcategory_match =
          if subcategory_slugs.present?
            solution.subcategories&.any? do |subcategory|
              subcategory_slugs.include?(subcategory.fields[:slug])
            end
          else
            true
          end

        ways_to_buy_match =
          if ways_to_buy_slugs.present?
            ways_to_buy_slugs.include?(solution.ways_to_buy&.fields&.[](:slug))
          else
            true
          end

        subcategory_match && ways_to_buy_match
      end
    end
  end
end
