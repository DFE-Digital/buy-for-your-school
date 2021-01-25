require "rails_helper"

RSpec.describe Journey, type: :model do
  it { should have_many(:steps) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:liquid_template) }
  end

  it "captures the category" do
    journey = build(:journey, :catering)
    expect(journey.category).to eql("catering")
  end
end
