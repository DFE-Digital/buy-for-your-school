require Rails.root.join("db/migrate/20210729145738_associate_existing_journeys.rb")

RSpec.describe AssociateExistingJourneys do
  include_context "with data migrations"

  let(:previous_version) { 20_210_729_144_528 }
  let(:current_version) { 20_210_729_145_738 }

  context "when there are broken journeys and no category" do
    before do
      # build and persist a category with no slug and no validation
      # as this column is not expected to exist yet
      category = build(:category, slug: nil)
      category.save!(validate: false)
      create_list(:journey, 10, category: category)
      Category.delete_all
      Journey.update_all(category_id: nil)
      stub_contentful_category(fixture_filename: "journey-with-multiple-entries.json")
    end

    it "creates and associates to the catering category" do
      expect(Journey.count).to eq 10
      expect(Category.count).to eq 0
      expect(Journey.first.category_id).to eq nil

      expect(Rollbar).to receive(:info)
          .with("Migration: Journeys associated to a category",
                journeys_total: 10,
                journeys_updated: 10,
                contentful_category_id: "contentful-category-entry",
                contentful_category_title: "Catering")

      expect { up }.to change(Category, :count).from(0).to(1)

      expect(Category.first.title).to eq "Catering"
      expect(Journey.first.category_id).not_to eq nil
    end
  end
end
