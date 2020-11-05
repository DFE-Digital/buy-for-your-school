require "rails_helper"

RSpec.describe Plan, type: :model do
  it { should have_many(:questions) }

  it "captures the category" do
    plan = build(:plan, :catering)
    expect(plan.category).to eql("catering")
  end

  it "stores an identifier for the next Contentful Entry" do
    plan = build(:plan, :catering, next_entry_id: "47EI2X2T5EDTpJX9WjRR9p")
    expect(plan.next_entry_id).to eql("47EI2X2T5EDTpJX9WjRR9p")
  end
end
