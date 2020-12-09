require "rails_helper"

RSpec.describe CheckboxAnswers, type: :model do
  it { should belong_to(:step) }

  describe "#response" do
    it "returns an array of strings" do
      answer = build(:checkbox_answers, response: ["Blue", "Green"])
      expect(answer.response).to eq(["Blue", "Green"])
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end
end
