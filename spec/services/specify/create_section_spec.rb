require "rails_helper"

RSpec.describe CreateSection do
  let(:journey) { create(:journey) }
  let(:contentful_section) { double(id: "5m26U35YLau4cOaJq6FXZA", title: "Section A") }

  describe "#call" do
    it "creates a new section" do
      expect {
        described_class.new(
          journey:,
          contentful_section:,
          order: 0,
        ).call
      }.to change(Section, :count).by(1)

      new_section = Section.last
      expect(new_section.title).to eql("Section A")
      expect(new_section.journey).to eql(journey)
      expect(new_section.order).to be(0)
    end
  end
end
