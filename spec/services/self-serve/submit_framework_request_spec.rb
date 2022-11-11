require "rails_helper"

describe SubmitFrameworkRequest do
  let(:email_confirmation) { double(call: true) }
  let(:request) { create(:framework_request, message_body: "An energy case") }
  let(:referrer) { nil }
  let(:email_confirmation_parameters) { anything }

  before do
    allow(Emails::Confirmation).to receive(:new).with(email_confirmation_parameters).and_return(email_confirmation)
    allow(Support::CategoryDetection).to receive(:results_for).with("An energy case", anything).and_return(category_d: category_detection_results)
  end

  describe "#call" do
    context "when a category can be detected for the given request text" do
      let(:electricity) { create(:support_category, title: "Electricity") }
      let(:category_detection_results) { [Support::CategoryDetection.new(category_id: electricity.id)] }

      it "sets that category on the new case" do
        described_class.new(request:, referrer:).call
        expect(Support::Case.last.category).to eq(electricity)
      end
    end

    context "when a category cannot be detected for the given request text" do
      let(:category_detection_results) { [] }

      it "the case category remains nil" do
        described_class.new(request:, referrer:).call
        expect(Support::Case.last.category).to be_nil
      end
    end
  end
end
