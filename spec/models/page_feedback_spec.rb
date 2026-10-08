require "rails_helper"

RSpec.describe PageFeedback, type: :model do
  subject(:page_feedback) do
    described_class.new(
      page_url: "/categories/catering",
      page_useful: true,
      feedback: "The page was helpful.",
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:page_url) }

    it { expect(page_feedback).to validate_inclusion_of(:page_useful).in_array([true, false]) }

    it { is_expected.to validate_length_of(:feedback).is_at_most(250) }
  end

  describe "valid record" do
    it "is valid with page_url, page_useful and feedback" do
      expect(page_feedback).to be_valid
    end
  end
end
