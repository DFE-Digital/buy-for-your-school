module AzureAiSearch
  class SolutionIndexSchema
    INDEX = ENV.fetch("AZURE_AI_SEARCH_INDEX_NAME", "solution-data")
    SEMANTIC_CONFIGURATION = ENV.fetch("AZURE_AI_SEARCH_SEMANTIC_CONFIGURATION", "solution-semantic-config")

    def self.to_h
      {
        name: INDEX,
        fields: fields,
        semantic: semantic_configuration,
      }
    end

    def self.fields
      [
        { name: "id", type: "Edm.String", key: true, searchable: false, filterable: true, retrievable: true },
        { name: "title", type: "Edm.String", searchable: true, filterable: true, sortable: true, retrievable: true },
        { name: "description", type: "Edm.String", searchable: true, retrievable: true },
        { name: "summary", type: "Edm.String", searchable: true, retrievable: true },
        { name: "slug", type: "Edm.String", searchable: false, filterable: true, retrievable: true },
        { name: "provider_reference", type: "Edm.String", searchable: true, filterable: true, retrievable: true },
        {
          name: "primary_category",
          type: "Edm.ComplexType",
          fields: [
            { name: "id", type: "Edm.String", searchable: false, filterable: true, retrievable: true },
            { name: "title", type: "Edm.String", searchable: true, filterable: true, retrievable: true },
            { name: "slug", type: "Edm.String", searchable: false, filterable: true, retrievable: true },
          ],
        },
      ]
    end
    private_class_method :fields

    def self.semantic_configuration
      {
        configurations: [
          {
            name: SEMANTIC_CONFIGURATION,
            prioritizedFields: {
              titleField: { fieldName: "title" },
              prioritizedContentFields: [
                { fieldName: "description" },
                { fieldName: "summary" },
              ],
              prioritizedKeywordsFields: [
                { fieldName: "provider_reference" },
              ],
            },
          },
        ],
      }
    end
    private_class_method :semantic_configuration
  end
end
