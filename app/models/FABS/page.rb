require "ostruct"

module FABS
  class Page
    include ActiveModel::Model
    include HasRelatedContent

    attr_reader :id, :title, :body, :description, :slug, :parent

    def initialize(entry)
      @id = entry.id
      @title = entry.fields[:title]
      @body = entry.fields[:body]
      @description = entry.fields[:description]
      @slug = entry.fields[:slug]
      parent_entry = entry.fields[:parent]
      @parent = build_parent_from_entry(parent_entry)
      super
    end

    def self.find_by_slug!(slug)
      entry = ContentfulClient.entries(
        content_type: "page",
        'fields.slug': slug,
        include: 4,
      ).first
      raise ContentfulRecordNotFoundError.new("Page not found", slug:) unless entry

      new(entry)
    end

  private

    def build_parent_from_entry(parent_entry)
      return nil unless parent_entry

      content_type_id = parent_entry.respond_to?(:content_type) ? parent_entry.content_type&.id : nil

      case content_type_id
      when "category"
        FABS::Category.new(parent_entry)
      when "page"
        FABS::Page.new(parent_entry)
      end
    end
  end
end
