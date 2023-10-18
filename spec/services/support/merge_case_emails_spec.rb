RSpec.describe Support::MergeCaseEmails do
  subject(:merge) { described_class.new(from_case:, to_case:, agent:) }

  let(:agent) { ::Support::AgentPresenter.new(create(:support_agent)) }
  let(:from_case) { create(:support_case, action_required: true) }
  let(:to_case) { create(:support_case, action_required: false) }

  context "when from_case has emails attached" do
    before do
      create_list(:support_email, 2, ticket: from_case)
    end

    it "moves emails from the from_case to the to_case" do
      expect(from_case.emails.count).to be 2
      expect(to_case.emails.count).to be 0

      merge.call

      expect(from_case.emails.count).to be 0
      expect(to_case.emails.count).to be 2
    end

    it "updates the from_case and to_case statuses" do
      expect(from_case.closed?).to be false
      expect(from_case.action_required?).to be true
      expect(to_case.action_required?).to be false

      merge.call

      expect(from_case.reload.closed?).to be true
      expect(from_case.closure_reason).to eql "email_merge"
      expect(from_case.action_required?).to be false
      expect(to_case.action_required?).to be true
    end
  end

  context "when the from_case has interactions" do
    before do
      create_list(:support_interaction, 2, case_id: from_case.id)
    end

    it "moves the interactions from the from_case to the to_case" do
      expect(from_case.interactions.count).to be 2
      expect(to_case.interactions.count).to be 0

      merge.call

      expect(from_case.interactions.count).to be 2
      expect(to_case.interactions.count).to be 3
    end
  end
end
