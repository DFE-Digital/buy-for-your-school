require "rails_helper"

RSpec.describe Journey, type: :model do
  it { should have_many(:steps) }

  it "captures the category" do
    journey = build(:journey, :catering)
    expect(journey.category).to eql("catering")
  end

  it "stores an identifier for the next Contentful Entry" do
    journey = build(:journey, :catering, next_entry_id: "47EI2X2T5EDTpJX9WjRR9p")
    expect(journey.next_entry_id).to eql("47EI2X2T5EDTpJX9WjRR9p")
  end
end
