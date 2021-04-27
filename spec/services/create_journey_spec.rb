require "rails_helper"

RSpec.describe CreateJourney do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry"
    ) do
      example.run
    end
  end

  describe "#call" do
    it "creates a new journey" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json"
      )
      expect { described_class.new(category_name: "catering", user: build(:user)).call }
        .to change { Journey.count }.by(1)
      expect(Journey.last.category).to eql("catering")
    end

    it "associates the new journey with the given user" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json"
      )
      user = create(:user)

      described_class.new(category_name: "catering", user: user).call

      expect(Journey.last.user).to eq(user)
    end

    it "sets started to true (until questions have been answered)" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json"
      )
      described_class.new(category_name: "catering", user: build(:user)).call
      expect(Journey.last.started).to eq(true)
    end

    it "sets last_worked_on to now" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json"
      )

      described_class.new(category_name: "catering", user: build(:user)).call

      expect(Journey.last.last_worked_on).to eq(Time.zone.now)
    end

    it "stores a copy of the Liquid template" do
      stub_contentful_category(
        fixture_filename: "category-with-liquid-template.json"
      )

      described_class.new(category_name: "catering", user: build(:user)).call

      expect(Journey.last.liquid_template)
        .to eql("<article id='specification'><h1>Liquid {{templating}}</h1></article>")
    end

    context "when the journey cannot be saved" do
      it "raises an error" do
        stub_contentful_category(
          fixture_filename: "category-with-liquid-template.json",
          stub_sections: true
        )

        # Force a validation error by not providing a category_name
        expect { described_class.new(category_name: nil, user: build(:user)).call }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
