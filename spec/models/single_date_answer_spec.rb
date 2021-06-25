require "rails_helper"

RSpec.describe SingleDateAnswer, type: :model do
  it { is_expected.to belong_to(:step) }

  describe "#response" do
    it "returns a date" do
      answer = build(:single_date_answer, response: Date.new(2020, 10, 1))
      expect(answer.response).to eq(Date.new(2020, 10, 1))
    end
  end

  describe "validations" do
    it "validates missing response" do
      answer = build(:single_date_answer, response: nil)

      expect(answer.valid?).to eq(false)
      expect(answer.errors.full_messages.first).to include(I18n.t("activerecord.errors.models.single_date_answer.attributes.response"))
    end
  end

  describe "#update_task_counters" do
    it_behaves_like "task_counters", :single_date, :single_date_answer
  end
end
