require Rails.root.join("db/migrate/20210825142733_add_slugs_to_existing_categories")

RSpec.describe AddSlugsToExistingCategories do
  include_context "with data migrations"

  let(:previous_version) { 20_210_825_142_114 }
  let(:current_version) { 20_210_825_142_733 }

  context "when there are broken categories" do
    before do
      create(:category, contentful_id: "contentful-category-entry", slug: nil)
      stub_contentful_category(fixture_filename: "mfd-radio-question.json")
    end

    it "populates the slug" do
      expect(Category.count).to eq 1
      expect(Category.first.slug).to eq nil

      expect { up }.to change { Category.where(slug: nil).count }.from(1).to(0)

      expect(Category.first.slug).to eq "mfd"
    end
  end
end
