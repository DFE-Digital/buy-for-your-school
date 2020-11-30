require "rails_helper"

RSpec.describe RadioAnswer, type: :model do
  it { should belong_to(:step) }

  it "captures the users response as a string" do
    answer = build(:radio_answer, response: "Yellow")
    expect(answer.response).to eql("Yellow")
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end
end
