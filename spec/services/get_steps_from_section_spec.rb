require "rails_helper"

RSpec.describe GetStepsFromSection do
  describe "#call" do
    it "returns the list of entry objects referenced by the section list" do
      section = fake_contentful_section(
        contentful_fixture_filename: "sections/journey-with-multiple-entries-section.json"
      )

      result = described_class.new(section: section).call

      expect(result).to be_kind_of(Array)
      # INFO: We should test this is a Contentful::Entry however it wasn't
      # possible to create an instance_double due to an unusual way the object
      # is constructed within the gem. Creating the object seems overly complex.
      expect(result.first.id).to eq("radio-question")
    end

    context "when the same entry is found twice" do
      it "returns an error message" do
        section = fake_contentful_section(
          contentful_fixture_filename: "sections/journey-with-repeat-entries-section.json"
        )

        expect(Rollbar).to receive(:error)
          .with("A repeated Contentful entry was found in the same section",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "radio-question")
          .and_call_original

        expect {
          described_class.new(section: section).call
        }.to raise_error(GetStepsFromSection::RepeatEntryDetected)
      end
    end
  end
end
