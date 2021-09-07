RSpec.describe CurrencyAnswer, type: :model do
  it { is_expected.to belong_to(:step) }

  describe "#response" do
    it "correctly strips out commas from a string" do
      answer = build(:currency_answer, response: "1,000.01")
      expect(answer.response).to eq(1000.01)
    end

    it "returns a float" do
      answer = build(:currency_answer, response: "1000.01")
      expect(answer.response).to eq(1000.01)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end

  describe "#update_task_counters" do
    it_behaves_like "task_counters", :currency, :currency_answer
  end
end
