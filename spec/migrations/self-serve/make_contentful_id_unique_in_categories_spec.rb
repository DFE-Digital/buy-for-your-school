require Rails.root.join("db/migrate/20210827160410_make_contentful_id_unique_in_categories")

RSpec.describe MakeContentfulIdUniqueInCategories do
  include_context "with data migrations"

  let(:previous_version) { 20_210_825_142_733 }
  let(:current_version) { 20_210_827_160_410 }

  context "when adding a category with existing contentful_id" do
    it "throws validation error" do
      create(:category, contentful_id: "contentful-category-entry")

      expect { up }.to change { ActiveRecord::Base.connection.index_exists?(:categories, :contentful_id, unique: true) }.from(false).to(true)
      expect { build(:category, contentful_id: "contentful-category-entry").save!(validate: false) }
        .to raise_error(
          ActiveRecord::RecordNotUnique,
          /PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_categories_on_contentful_id"/,
        )
    end
  end
end
