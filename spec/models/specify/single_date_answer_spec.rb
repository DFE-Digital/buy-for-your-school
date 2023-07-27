RSpec.describe SingleDateAnswer, type: :model do
  let(:answer) { build(:single_date_answer, response: date) }

  it { is_expected.to belong_to(:step) }

  describe "#update_task_counters" do
    it_behaves_like "task_counters", :single_date, :single_date_answer
  end

  describe "#response" do
    let(:date) { Date.new(2020, 10, 1) }

    it "returns a date" do
      expect(answer.response).to eq date
    end
  end

  describe "validations" do
    let(:date) { nil }

    it "validates missing response" do
      expect(answer.valid?).to be false

      # activerecord.errors.models.single_date_answer.attributes.response
      expect(answer.errors.full_messages.first).to end_with "Provide a real date for this answer"
    end
  end
end
