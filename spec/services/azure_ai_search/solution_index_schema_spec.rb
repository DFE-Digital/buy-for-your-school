require "rails_helper"

RSpec.describe AzureAiSearch::SolutionIndexSchema do
  describe ".to_h" do
    it "builds the Azure AI Search index schema for solution documents" do
      schema = described_class.to_h

      expect(schema).to include(
        name: "solution-data",
        fields: include(
          include(name: "id", type: "Edm.String", key: true),
          include(name: "title", type: "Edm.String", searchable: true),
          include(name: "provider_reference", type: "Edm.String", searchable: true),
          include(name: "primary_category", type: "Edm.ComplexType"),
        ),
      )
      expect(schema[:fields]).not_to include(include(name: "provider_name"))
      expect(schema[:fields]).not_to include(include(name: "buying_option_type"))
      expect(schema.dig(:semantic, :configurations, 0)).to include(
        name: "solution-semantic-config",
        prioritizedFields: include(
          titleField: { fieldName: "title" },
          prioritizedContentFields: include({ fieldName: "description" }, { fieldName: "summary" }),
        ),
      )
    end
  end
end
