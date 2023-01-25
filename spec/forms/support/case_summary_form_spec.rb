RSpec.describe Support::CaseSummaryForm, type: :model do
  subject(:form) { described_class.new }

  describe "#source_options" do
    it "returns the source options as title-id pairs" do
      expect(form.source_options).to include(
        OpenStruct.new(title: "Specify case", id: "digital"),
        OpenStruct.new(title: "North West (NW) Hub", id: "nw_hub"),
        OpenStruct.new(title: "South West (SW) Hub", id: "sw_hub"),
        OpenStruct.new(title: "Email", id: "incoming_email"),
        OpenStruct.new(title: "Find a Framework", id: "faf"),
        OpenStruct.new(title: "Engagement and Outreach (E&O)", id: "engagement_and_outreach"),
        OpenStruct.new(title: "Schools Commercial Team (SCT)", id: "schools_commercial_team"),
      )
    end
  end
end
