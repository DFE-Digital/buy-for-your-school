module AzureAiSearch
  class ContentfulDocument
    def self.from_record(record, action: "mergeOrUpload")
      content_type = content_type_for(record)
      return unless content_type

      title = record.title
      slug = record.slug
      return if title.blank? || slug.blank?

      document = {
        "@search.action": action,
        id: document_id(record.id, content_type),
        content_type:,
        title: string_value(title),
        description: string_value(description_for(record)),
        body: string_value(body_for(record)),
        slug: string_value(slug),
      }
      if record.is_a?(Solution)
        document[:provider_reference] = string_value(record.provider_reference)
        document[:primary_category] = primary_category(record.primary_category)
      end
      document.compact
    end

    def self.delete(id)
      { "@search.action": "delete", id: }
    end

    def self.document_id(id, content_type)
      "#{content_type}-#{id}"
    end

    def self.content_type_for(record)
      case record
      when Solution then "solution"
      when FABS::Category then "category"
      when FABS::Page then "page"
      end
    end
    private_class_method :content_type_for

    def self.description_for(record)
      case record
      when FABS::Category then record.body_title
      else record.description
      end
    end
    private_class_method :description_for

    def self.body_for(record)
      case record
      when Solution then record.summary
      when FABS::Category then record.body_description
      when FABS::Page then record.body
      end
    end
    private_class_method :body_for

    def self.primary_category(category)
      return unless category

      {
        id: string_value(category.id),
        title: string_value(category.title),
        slug: string_value(category.slug),
      }.compact
    end
    private_class_method :primary_category

    def self.string_value(value)
      value.to_s if value.present? && value != true && value != false
    end
    private_class_method :string_value
  end
end
