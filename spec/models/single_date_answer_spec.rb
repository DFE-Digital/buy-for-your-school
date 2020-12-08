require "rails_helper"

RSpec.describe SingleDateAnswer, type: :model do
  it { should belong_to(:step) }

  describe "#response" do
    it "returns a date" do
      answer = build(:single_date_answer, response: Date.new(2020, 10, 1))
      expect(answer.response).to eq(Date.new(2020, 10, 1))
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end
end
