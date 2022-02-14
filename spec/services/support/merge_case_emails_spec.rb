RSpec.describe Support::MergeCaseEmails do
  subject(:merge) { described_class.new(from_case: from_case, to_case: to_case) }

  let(:from_case) { create(:support_case) }
  let(:to_case) { create(:support_case) }

  context "when from_case has emails attached" do
    before do
      create_list(:support_email, 2, case_id: from_case.id)
    end

    it "moves emails from the from_case to the to_case" do
      expect(from_case.emails.count).to be 2
      expect(to_case.emails.count).to be 0

      merge.call

      expect(from_case.emails.count).to be 0
      expect(to_case.emails.count).to be 2
    end

    it "sets from_case to closed and to_case to pending" do
      expect(from_case.closed?).to be false
      expect(to_case.pending?).to be false

      merge.call

      expect(from_case.closed?).to be true
      expect(to_case.pending?).to be true
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

      expect(from_case.interactions.count).to be 0
      expect(to_case.interactions.count).to be 2
    end
  end

  context "when the from_case is not 'new'" do
    before { from_case.pending! }

    it "raises Support::CaseNotNew error" do
      expect { merge.call }.to raise_error(Support::MergeCaseEmails::CaseNotNewError)
    end
  end
end
