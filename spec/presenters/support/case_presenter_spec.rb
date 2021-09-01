require "rails_helper"

RSpec.describe Support::CasePresenter do
  let(:kase) do
    OpenStruct(
      state: "foo",
      interactions: [double],
      category: double,
      contact: double,
    )
  end

  let(:presenter) { described_class.new(kase) }

  describe "#state" do
    it "returns an upcase state" do
      expect(presenter.state).to eq("FOO")
    end
  end

  describe "#interactions" do
    it "returns an array of decorated interactions" do
      expect(presenter.interactions.first.class).to eq(Support::InteractionPresenter)
    end
  end

  describe "#contact" do
    it "returns a decorated contact" do
      expect(presenter.contact.class).to eq(Support::ContactPresenter)
    end
  end

  describe "#category" do
    it "returns a decorated category" do
      expect(presenter.category.class).to eq(Support::CategoryPresenter)
    end
  end
end
