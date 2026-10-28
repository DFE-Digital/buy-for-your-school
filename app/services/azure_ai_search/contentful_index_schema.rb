module AzureAiSearch
  class ContentfulIndexSchema
    INDEX = ENV.fetch("AZURE_AI_SEARCH_INDEX_NAME", "contentful-data")
    SEMANTIC_CONFIGURATION = ENV.fetch("AZURE_AI_SEARCH_SEMANTIC_CONFIGURATION", "contentful-v1")
    TITLE_SCORING_PROFILE = "title-weight-v1".freeze
    ENGLISH_ANALYZER = "en.microsoft".freeze

    def self.to_h
      {
        name: INDEX,
        fields:,
        semantic: semantic_configuration,
        scoringProfiles: [
          {
            name: TITLE_SCORING_PROFILE,
            text: { weights: { title: 2 } },
          },
        ],
        defaultScoringProfile: TITLE_SCORING_PROFILE,
      }
    end

    def self.fields
      [
        { name: "id", type: "Edm.String", key: true, searchable: false, filterable: true, retrievable: true },
        { name: "content_type", type: "Edm.String", searchable: false, filterable: true, facetable: true, retrievable: true },
        { name: "title", type: "Edm.String", searchable: true, filterable: true, sortable: true, retrievable: true, analyzer: ENGLISH_ANALYZER },
        { name: "description", type: "Edm.String", searchable: true, retrievable: true, analyzer: ENGLISH_ANALYZER },
        { name: "body", type: "Edm.String", searchable: true, retrievable: true, analyzer: ENGLISH_ANALYZER },
        { name: "slug", type: "Edm.String", searchable: false, filterable: true, retrievable: true },
        { name: "provider_reference", type: "Edm.String", searchable: true, filterable: true, retrievable: true },
        {
          name: "primary_category",
          type: "Edm.ComplexType",
          fields: [
            { name: "id", type: "Edm.String", searchable: false, filterable: true, retrievable: true },
            { name: "title", type: "Edm.String", searchable: true, filterable: true, retrievable: true, analyzer: ENGLISH_ANALYZER },
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
                { fieldName: "body" },
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
