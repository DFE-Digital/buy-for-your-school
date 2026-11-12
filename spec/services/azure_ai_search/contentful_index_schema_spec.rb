require "rails_helper"

RSpec.describe AzureAiSearch::ContentfulIndexSchema do
  describe ".to_h" do
    it "defines a separate index that supports all Contentful result types" do
      schema = described_class.to_h

      expect(schema).to include(
        name: "contentful-data",
        fields: include(
          include(name: "id", type: "Edm.String", key: true),
          include(name: "content_type", type: "Edm.String", filterable: true, facetable: true),
          include(name: "title", type: "Edm.String", searchable: true),
          include(name: "description", type: "Edm.String", searchable: true),
          include(name: "body", type: "Edm.String", searchable: true),
        ),
        scoringProfiles: [
          {
            name: "title-weight-v1",
            text: { weights: { title: 2 } },
          },
        ],
        defaultScoringProfile: "title-weight-v1",
      )
    end
  end
end
