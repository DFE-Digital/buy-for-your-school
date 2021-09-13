RSpec.describe CreateSupportEnquiry do
  subject(:service) { described_class.new(support_request) }

  let(:result) { service.call }

  describe "#call" do
    context "when a support request is given" do
      let(:support_request) { create(:support_request, :with_specification) }

      it "creates a new support enquiry record" do
        expect(result).to eq Support::Enquiry.find_by(telephone: "0151 000 0000")
      end

      it "attaches a support document" do
        expect(result.documents.count).to eq 1
      end
    end

    context "when no support request is given " do
      let(:support_request) { create(:support_request) }

      it "creates a new support enquiry record" do
        expect(result).to eq Support::Enquiry.find_by(telephone: "0151 000 0000")
      end

      it "has no support document" do
        expect(result.documents.count).to eq 0
      end
    end
  end
end
