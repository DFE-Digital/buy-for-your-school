require "ostruct"

module FABS
  class Category
    include ActiveModel::Model
    include HasRelatedContent

    attr_reader :id, :title, :description, :slug, :subcategories, :banner

    def initialize(entry)
      @id = entry.id
      @title = entry.fields[:title]
      @description = entry.fields[:description]
      @slug = entry.fields[:slug]
      @subcategories = entry.fields.fetch(:subcategories, []).map { Subcategory.new(entry) }.sort_by(&:title)
      @banner = entry.fields[:banner] ? Banner.new(entry.fields[:banner]) : nil
      super
    end

    def solutions
      Solution.all(category_id: id)
    end

    def self.all
      category_ids = Solution.unique_category_ids
      return [] if category_ids.blank?

      params = {
        content_type: "category",
        select: "sys.id,fields.title,fields.description,fields.slug,fields.banner",
        order: "fields.title",
        "sys.id[in]" => category_ids.join(","),
        include: 1,
      }

      ContentfulClient.entries(params).map { |entry| new(entry) }
    end

    def self.search(query: "")
      ContentfulClient.entries(
        content_type: "category",
        query: query,
        select: "sys.id,fields.title,fields.description,fields.slug,fields.banner",
        include: 1
      ).map { |entry| new(entry) }
    end

    def self.rehydrate_from_search(result)
      return nil unless result

      new(OpenStruct.new(
            id: result["id"],
            fields: { title: result["title"], slug: result["slug"] }
          ))
    end

    def to_param
      slug
    end

    def self.find_by_slug!(slug)
      entry = ContentfulClient.entries(
        content_type: "category",
        'fields.slug': slug,
        include: 1
      ).first

      raise ContentfulRecordNotFoundError.new("Category not found", slug: slug) unless entry

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
