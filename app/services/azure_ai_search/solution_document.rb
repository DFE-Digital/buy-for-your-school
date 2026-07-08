module AzureAiSearch
  class SolutionDocument
    def self.from_solution(solution, action: "mergeOrUpload")
      {
        "@search.action": action,
        id: string_value(solution.id),
        title: string_value(solution.title),
        description: string_value(solution.description),
        summary: string_value(solution.summary),
        slug: string_value(solution.slug),
        provider_reference: string_value(solution.provider_reference),
        primary_category: primary_category(solution.primary_category),
      }.compact
    end

    def self.delete(id)
      {
        "@search.action": "delete",
        id:,
      }
    end

    def self.primary_category(category)
      return nil unless category

      {
        id: string_value(category.id),
        title: string_value(category.title),
        slug: string_value(category.slug),
      }
    end
    private_class_method :primary_category

    def self.string_value(value)
      return nil if value.nil? || value == false || value == true

      value.to_s
    end
    private_class_method :string_value
  end
end
