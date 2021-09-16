RSpec.describe ContentfulEntryPresenter do
  describe "#contentful_url" do
    it "returns Contentful URL" do
      entry = stub_contentful_category(fixture_filename: "radio-question.json", stub_sections: false, stub_tasks: false)
      presenter = described_class.new(entry)
      expect(presenter.contentful_url).to eq "https://app.contentful.com/spaces/rwl7tyzv9sys/environments/develop/entries/contentful-category-entry"
    end
  end

  describe "#updated_at" do
    it "returns formatted time" do
      entry = stub_contentful_category(fixture_filename: "radio-question.json", stub_sections: false, stub_tasks: false)
      presenter = described_class.new(entry)
      expect(presenter.updated_at).to eq "20 January 2021 - 03:06:12 pm"
    end
  end
end
