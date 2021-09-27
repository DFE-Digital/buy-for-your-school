require Rails.root.join("db/migrate/20210827161206_add_timestamp_defaults_to_categories")

RSpec.describe AddTimestampDefaultsToCategories do
  include_context "with data migrations"

  let(:previous_version) { 20_210_827_160_410 }
  let(:current_version) { 20_210_827_161_206 }

  context "when calling Category.upsert" do
    it "defaults timestamps" do
      expect { upsert }
        .to raise_error(
          ActiveRecord::NotNullViolation,
          /PG::NotNullViolation: ERROR:  null value in column "created_at" of relation "categories" violates not-null constraint/,
        )

      # rollback to prevent ActiveRecord::StatementInvalid
      ActiveRecord::Base.connection.execute "ROLLBACK"
      ActiveRecord::Base.connection.execute "BEGIN"

      expect(Category.count).to be_zero

      up

      expect { upsert }.not_to raise_error
      expect(Category.count).to eq 1
      expect(Category.first.created_at).not_to be_nil
      expect(Category.first.updated_at).not_to be_nil
    end
  end

private

  def upsert
    contentful_category = stub_contentful_category(fixture_filename: "radio-question.json")
    Category.upsert(
      {
        title: contentful_category.title,
        description: contentful_category.description,
        liquid_template: contentful_category.combined_specification_template,
        contentful_id: contentful_category.id,
        slug: contentful_category.slug,
      },
      unique_by: :contentful_id,
    )
  end
end
