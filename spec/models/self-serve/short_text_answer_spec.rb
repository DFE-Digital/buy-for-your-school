RSpec.describe ShortTextAnswer, type: :model do
  it { is_expected.to belong_to(:step) }

  it "captures the users response as a string" do
    answer = build(:short_text_answer, response: "Yellow")
    expect(answer.response).to eql("Yellow")
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end

  describe "#update_task_counters" do
    it_behaves_like "task_counters", :short_text, :short_text_answer
  end
end
