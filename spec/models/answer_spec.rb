require "rails_helper"

RSpec.describe Answer, type: :model do
  it { should belong_to(:question) }

  it "captures the users response as a string" do
    answer = build(:answer, response: "Yellow")
    expect(answer.response).to eql("Yellow")
  end
end
