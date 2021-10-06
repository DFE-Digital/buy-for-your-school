require Rails.root.join("db/migrate/20210825142733_add_slugs_to_existing_categories")

RSpec.describe AddSlugsToExistingCategories do
  include_context "with data migrations"

  let(:previous_version) { 20_210_825_142_114 }
  let(:current_version) { 20_210_825_142_733 }

  let(:category) do
    build(:category,
          slug: nil,
          description: nil,
          contentful_id: "contentful-category-entry")
  end

  before do
    category.save!(validate: false)
  end

  context "when there are broken categories" do
    before do
      stub_contentful_category(fixture_filename: "mfd-radio-question.json")
    end

    it "populates the slug and description" do
      expect(Category.count).to eq 1
      expect(Category.first.slug).to eq nil

      expect { up }.to change { Category.where(slug: nil).count }.from(1).to(0)

      expect(Category.first.slug).to eq "mfd"
    end
  end

  context "when the Contentful category does not exist" do
    before do
      allow(stub_client).to receive(:by_id).with("contentful-category-entry").and_return(nil)
    end

    it "makes no changes" do
      expect(Category.count).to eq 1
      expect(Category.first.slug).to eq nil

      expect { up }.not_to change { Category.where(slug: nil).count }.from(1)

      expect(Category.first.slug).to be_nil
    end
  end
end
