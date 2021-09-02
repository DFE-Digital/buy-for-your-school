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

  # simulate Rollbar error #64
  context "when the Contentful category does not exist" do
    before do
      create(:category, contentful_id: "contentful-category-entry", slug: nil)
      allow(stub_client).to receive(:by_id).with("contentful-category-entry").and_return(nil)
    end

    it "makes no changes" do
      expect(Category.count).to eq 1
      expect(Category.first.slug).to eq nil

      expect { up }.not_to change { Category.where(slug: nil).count }.from(1)

      expect(Category.first.slug).to be_nil
    end
  end

  # simulate Rollbar error #65
  context "when there is invalid existing data" do
    before do
      # simulate an existing invalid record
      build(:category, description: nil, contentful_id: "contentful-category-entry", slug: nil).save!(validate: false)
      stub_contentful_category(fixture_filename: "mfd-radio-question.json")
    end

    it "bypasses validation and populates the slug" do
      expect(Category.count).to eq 1
      expect(Category.first.slug).to eq nil

      expect { up }.to change { Category.where(slug: nil).count }.from(1).to(0)

      expect(Category.first.slug).to eq "mfd"
    end
  end
end
