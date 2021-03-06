require "rails_helper"

RSpec.describe CreateJourney do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry",
    ) do
      example.run
    end
  end

  let(:user) { build(:user) }
  let(:category) { build(:category, contentful_id: "contentful-category-entry") }

  describe "#call" do
    it "creates a new journey" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json",
      )

      expect {
        described_class.new(category: category, user: user).call
      }.to change(Journey, :count).by(1)

      last_journey = Journey.last
      expect(last_journey.category.title).to eql("Catering")
      expect(last_journey.category.contentful_id).to eql("contentful-category-entry")
    end

    it "associates the new journey with the given user" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json",
      )

      described_class.new(category: category, user: user).call

      expect(Journey.last.user).to eq(user)
    end

    it "sets started to true (until questions have been answered)" do
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json",
      )
      described_class.new(category: category, user: user).call
      expect(Journey.last.started).to eq(true)
    end

    it "sets updated_at to now" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      stub_contentful_category(
        fixture_filename: "category-with-no-steps.json",
      )

      described_class.new(category: category, user: user).call

      expect(Journey.last.updated_at).to eq(Time.zone.now)
    end

    # TODO: move liquid template specs to the Category
    describe "WIP multiple categories" do
      it "stores a copy of the Liquid template" do
        stub_contentful_category(
          fixture_filename: "category-with-liquid-template.json",
        )

        described_class.new(category: category, user: user).call

        # From fixtures
        # .to eql("<article id='specification'><h1>Liquid {{templating}}</h1></article>")
        expect(Journey.last.category.liquid_template)
          .to eql("Your answer was {{ answer_47EI2X2T5EDTpJX9WjRR9p }}") # from factory
      end

      # TODO: test when a journey cannot be saved
      # context "when the journey cannot be saved" do
      #   it "raises an error" do
      #     stub_contentful_category(
      #       fixture_filename: "category-with-no-title.json",
      #       stub_sections: true,
      #     )
      #     # Force a validation error by not providing an invalid category ID
      #     expect {
      #       described_class.new(category: category, user: user).call
      #     }.to raise_error(ActiveRecord::RecordInvalid)
      #   end
      # end
    end
  end
end
