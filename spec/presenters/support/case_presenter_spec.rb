RSpec.describe Support::CasePresenter do
  subject(:presenter) { described_class.new(support_case) }

  let(:agent) { OpenStruct.new(first_name: "Ronald", last_name: "McDonald") }

  let(:interaction) { OpenStruct.new(created_at: Time.zone.local(2000, 1, 30, 12)) }

  let(:support_case) do
    OpenStruct.new(
      state: "open",
      interactions: [interaction],
      agent: agent,
      category: double,
      contact: double,
      enquiry: OpenStruct.new(created_at: Time.zone.local(2000, 1, 30, 12)),
    )
  end

  describe "#state" do
    it "is uppercase" do
      expect(presenter.state).to eq("OPEN")
    end
  end

  describe "#agent_name" do
    # TODO: possible context where we render "UNASSIGNED" or similar?
    it "returns the name of the agent that's assigned to the case" do
      expect(presenter.agent_name).to eq("Ronald McDonald")
    end
  end

  describe "#received_at" do
    it "returns the formatted date on which the case was received" do
      expect(presenter.received_at).to eq("30 January 2000 at 12:00")
    end
  end

  describe "#last_updated_at" do
    it "returns the formatted date on which the case was last updated" do
      expect(presenter.last_updated_at).to eq("30 January 2000 at 12:00")
    end
  end

  describe "#interactions" do
    it "is decorated" do
      expect(presenter.interactions.first).to be_a(Support::InteractionPresenter)
    end
  end

  describe "#contact" do
    it "is decorated" do
      expect(presenter.contact).to be_a(Support::ContactPresenter)
    end
  end

  describe "#category" do
    xit "is decorated" do
      # FIXME: swap once CategoryPresenter is being used and namespace loads in the suite
      expect(presenter.category).to be_a(CategoryPresenter)
      # expect(presenter.category).to be_a(Support::CategoryPresenter)
    end
  end

  describe "#enquiry" do
    it "returns a decorated enquiry" do
      expect(presenter.enquiry).to be_a(Support::EnquiryPresenter)
    end
  end
end
