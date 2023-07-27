RSpec.describe CreateCategory do
  subject(:service) { described_class.new(contentful_category:) }

  let(:contentful_category) { stub_contentful_category(fixture_filename: "radio-question.json", stub_sections: false) }

  describe "#call" do
    it "persists a Contentful category" do
      category = service.call

      expect(category.title).to eq "Catering"
      expect(category.description).to eq "Catering description"
      expect(category.contentful_id).to eq "contentful-category-entry"
      expect(category.liquid_template).to eq "<article id='specification'><h1>Liquid {{templating}}</h1></article>"
      expect(category.slug).to eq "catering"
    end
  end
end
