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

  describe "#response=" do
    context "when the response only includes blank items" do
      it "should be invalid" do
        answer = build(:checkbox_answers, response: ["", ""])
        expect(answer.valid?).to eq(false)
      end
    end

    context "when the response a mix of present and blank items" do
      it "should only store the present values" do
        answer = build(:checkbox_answers, response: ["Foo", ""])
        expect(answer.response).to eq(["Foo"])
      end
    end
  end
end
