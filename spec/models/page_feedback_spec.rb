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

    it { is_expected.to validate_length_of(:feedback).is_at_most(250) }
  end

  describe "valid record" do
    it "is valid with page_url, page_useful and feedback" do
      expect(page_feedback).to be_valid
    end

    it "is invalid with nil page_useful" do
      page_feedback.page_useful = nil
      expect(page_feedback).not_to be_valid
    end
  end
end
