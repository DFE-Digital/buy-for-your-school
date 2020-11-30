require "rails_helper"

RSpec.describe ShortTextAnswer, type: :model do
  it { should belong_to(:step) }

  it "captures the users response as a string" do
    answer = build(:short_text_answer, response: "Yellow")
    expect(answer.response).to eql("Yellow")
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:response) }
  end
end
