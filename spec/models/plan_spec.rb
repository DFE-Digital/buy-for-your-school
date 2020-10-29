require "rails_helper"

RSpec.describe Plan, type: :model do
  it { should have_many(:questions) }

  it "captures the category" do
    plan = build(:plan, :catering)
    expect(plan.category).to eql("catering")
  end
end
