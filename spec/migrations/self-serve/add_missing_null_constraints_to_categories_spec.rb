require Rails.root.join("db/migrate/20210906101533_add_missing_null_constraints_to_categories")

RSpec.describe AddMissingNullConstraintsToCategories do
  include_context "with data migrations"

  let(:previous_version) { 20_210_827_161_206 }
  let(:current_version) { 20_210_906_101_533 }

  context "when creating a Category without a description" do
    it "fails due to null constraint" do
      expect { up }.to change {
        Category.reset_column_information
        Category.columns.find { |c| c.name == "description" }.null
      }.from(true).to(false)

      category = build(:category, description: nil)
      expect { category.save!(validate: false) }.to raise_error(
        ActiveRecord::NotNullViolation,
        /PG::NotNullViolation: ERROR:  null value in column "description" of relation "categories" violates not-null constraint/,
      )
    end
  end

  context "when creating a Category without a slug" do
    it "fails due to null constraint" do
      expect { up }.to change {
        Category.reset_column_information
        Category.columns.find { |c| c.name == "slug" }.null
      }.from(true).to(false)

      category = build(:category, slug: nil)
      expect { category.save!(validate: false) }.to raise_error(
        ActiveRecord::NotNullViolation,
        /PG::NotNullViolation: ERROR:  null value in column "slug" of relation "categories" violates not-null constraint/,
      )
    end
  end
end
