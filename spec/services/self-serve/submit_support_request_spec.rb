RSpec.describe SubmitSupportRequest do
  subject(:service) { described_class.new(support_request) }

  describe "#call" do
    let(:support_enquiry) { Support::Enquiry.last }

    context "when a support request is given" do
      let!(:support_request) { create(:support_request, :with_specification) }

      it "submits a new support enquiry record" do
        expect(support_request.phone_number).to eq support_enquiry.telephone
      end

      it "attaches a support document" do
        expect(support_enquiry.documents.count).to eq 1
      end
    end

    context "when no support request is given" do
      let!(:support_request) { create(:support_request) }

      it "submits a new support enquiry record" do
        expect(support_request.phone_number).to eq support_enquiry.telephone
      end

      it "has no support document" do
        expect(support_enquiry.documents.count).to eq 0
      end
    end
  end
end
