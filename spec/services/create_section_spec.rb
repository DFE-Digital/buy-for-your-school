require "rails_helper"

RSpec.describe CreateSection do
  let(:journey) { FactoryBot.create(:journey) }
  let(:contentful_section) { double(id: "5m26U35YLau4cOaJq6FXZA", title: "Section A") }

  describe "#call" do
    it "creates a new section" do
      expect { described_class.new(journey: journey, contentful_section: contentful_section, order: order).call }
        .to change { Section.count }.by(1)
      expect(Section.last.title).to eql("Section A")
      expect(Section.last.journey).to eql(journey)
    end
  end
end
