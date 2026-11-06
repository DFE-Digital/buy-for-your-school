require "rails_helper"

RSpec.describe AzureAiSearch::ContentfulDocument do
  describe ".from_record" do
    let(:category) do
      FABS::Category.new(OpenStruct.new(
                           id: "category-1",
                           fields: { title: "Catering", description: "Catering options", body_title: "Catering body title", body_description: "Details about catering", slug: "catering", subcategories: [] },
                         ))
    end

    it "serializes a solution with its type and common fields" do
      solution = Solution.new(OpenStruct.new(
                                id: "solution-1",
                                fields: {
                                  title: "Catering solution",
                                  description: "Buy catering",
                                  summary: "A catering summary",
                                  slug: "catering-solution",
                                  provider_reference: "REF-1",
                                  primary_category: category,
                                },
                              ))

      expect(described_class.from_record(solution)).to include(
        id: "solution-solution-1",
        content_type: "solution",
        title: "Catering solution",
        description: "Buy catering",
        body: "A catering summary",
      )
    end

    it "serializes categories and pages into the same common document shape" do
      page = FABS::Page.new(OpenStruct.new(
                              id: "page-1",
                              fields: { title: "Buying guidance", description: "Guidance description", body: "Guidance body content", slug: "buying-guidance", parent: nil },
                            ))

      expect(described_class.from_record(category)).to include(
        id: "category-category-1",
        content_type: "category",
        description: "Catering body title",
        body: "Details about catering",
      )
      expect(described_class.from_record(page)).to include(
        id: "page-page-1",
        content_type: "page",
        description: "Guidance description",
        body: "Guidance body content",
      )
    end

    it "does not index records without a title or slug" do
      page = FABS::Page.new(OpenStruct.new(id: "page-1", fields: { title: nil, slug: nil, description: nil, parent: nil }))

      expect(described_class.from_record(page)).to be_nil
    end
  end
end
