require "rails_helper"

describe SubmitFrameworkRequest do
  let(:email_confirmation) { double(call: true) }
  let(:request) { create(:framework_request, message_body: "An energy case", energy_alternative:, category: rfh_category, category_other:) }
  let(:referrer) { nil }
  let(:energy_alternative) { nil }
  let(:email_confirmation_parameters) { anything }
  let(:support_category) { create(:support_category, title: "Other (Energy)", slug: "other-energy") }
  let(:parent_rfh_category) { create(:request_for_help_category, title: "Energy and utilities", slug: "energy-and-utilities") }
  let(:rfh_category) { create(:request_for_help_category, title: "Other", slug: "other", support_category:, parent: parent_rfh_category, flow:) }
  let(:flow) { :services }
  let(:category_other) { "other energy requirements" }

  before do
    allow(Emails::Confirmation).to receive(:new).with(email_confirmation_parameters).and_return(email_confirmation)

    create(:support_organisation, urn: "1")
    create(:support_organisation, urn: "2")
    request.update!(school_urns: %w[1 2])
  end

  describe "#call" do
    it "only creates one case" do
      expect { described_class.new(request:, referrer:).call }.to change(Support::Case, :count).from(0).to(1)
    end

    it "sets the right category on the case" do
      described_class.new(request:, referrer:).call

      expect(Support::Case.last.category).to eq support_category
      expect(Support::Case.last.other_category).to eq category_other
    end

    it "sets the user selected category path on the case" do
      described_class.new(request:, referrer:).call

      expect(Support::Case.last.user_selected_category).to eq "Energy and utilities/Other - other energy requirements"
    end

    it "sets the detected category (same as the category) on the case" do
      described_class.new(request:, referrer:).call

      expect(Support::Case.last.detected_category).to eq support_category
    end

    it "sets the selected schools on the case" do
      described_class.new(request:, referrer:).call

      expect(Support::Case.last.participating_schools.pluck(:urn)).to match_array(%w[1 2])
    end

    it "sets the created case on the request" do
      described_class.new(request:, referrer:).call

      expect(request.support_case).to eq(Support::Case.last)
    end

    context "when it's an energy request" do
      let(:flow) { :energy }

      it "sends out the confirmation email for energy requests" do
        allow(Emails::ConfirmationEnergy).to receive(:new).with(email_confirmation_parameters).and_return(email_confirmation)
        expect(Emails::ConfirmationEnergy).to receive(:new).with(email_confirmation_parameters)
        described_class.new(request:, referrer:).call
      end
    end

    context "when energy bills have been uploaded" do
      let!(:bill_1) { create(:energy_bill, :pending, framework_request: request) }
      let!(:bill_2) { create(:energy_bill, :pending, framework_request: request) }

      before { allow(Emails::ConfirmationEnergy).to receive(:new).with(email_confirmation_parameters).and_return(email_confirmation) }

      it "sets their status to submitted" do
        described_class.new(request:, referrer:).call

        expect(bill_1.reload).to be_submitted
        expect(bill_2.reload).to be_submitted
      end

      it "connects them with the newly created case" do
        described_class.new(request:, referrer:).call

        expect(bill_1.reload.support_case).to eq(Support::Case.last)
        expect(bill_2.reload.support_case).to eq(Support::Case.last)
      end

      it "creates CaseAttachment records for each bill" do
        described_class.new(request:, referrer:).call

        expect(Support::CaseAttachment.find_by(attachable: bill_1).case).to eq(Support::Case.last)
        expect(Support::CaseAttachment.find_by(attachable: bill_2).case).to eq(Support::Case.last)
      end
    end

    context "when documents have been uploaded" do
      let!(:doc_1) { create(:document, :pending, framework_request: request) }
      let!(:doc_2) { create(:document, :pending, framework_request: request) }

      it "sets their status to submitted" do
        described_class.new(request:, referrer:).call

        expect(doc_1.reload).to be_submitted
        expect(doc_2.reload).to be_submitted
      end

      it "connects them with the newly created case" do
        described_class.new(request:, referrer:).call

        expect(doc_1.reload.support_case).to eq(Support::Case.last)
        expect(doc_2.reload.support_case).to eq(Support::Case.last)
      end

      it "creates CaseAttachment records for each bill" do
        described_class.new(request:, referrer:).call

        expect(Support::CaseAttachment.find_by(attachable: doc_1).case).to eq(Support::Case.last)
        expect(Support::CaseAttachment.find_by(attachable: doc_2).case).to eq(Support::Case.last)
      end
    end
  end
end
