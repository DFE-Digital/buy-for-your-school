require "rails_helper"

RSpec.describe GetExpertHelp, type: :model do
  describe "#initialize" do
    subject(:get_expert_help) { described_class.new(entry) }

    let(:entry) { get_expert_help_entry }

    it "sets the attributes" do
      expect(get_expert_help).to have_attributes(
        id: be_present,
        title: be_present,
        description: be_present,
      )
    end
  end

  describe ".content" do
    subject(:get_expert_help) { described_class.content }

    let(:entry) { get_expert_help_entry(id: "get-expert-help-id", title: "expert help", description: "Description A") }

    before do
      allow(ContentfulClient).to receive(:entries).and_return([entry])
    end

    it "fetches get expert help content from Contentful" do
      expect(get_expert_help).to be_present
      expect(get_expert_help).to be_a(described_class)
    end
  end

  def get_expert_help_entry(id: "get-expert-help-id", title: "Expert help", description: "Description")
    OpenStruct.new(
      id:,
      fields: {
        title:,
        description:,
      },
    )
  end
end
