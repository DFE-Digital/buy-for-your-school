RSpec.describe CreateSupportEnquiry do
  subject(:service) { described_class.new(support_request) }

  let(:result) { service.call }

  describe "#call" do
    context "when a support request is given" do
      let(:support_request) { create(:support_request) }

      it "creates a new support enquiry record" do
        expect(result).to eq Support::Enquiry.find_by(telephone: "0151 000 0000")
      end

      it "attaches a support document" do
        # xxxx
      end
    end

    context "when no support request is given" do
      let(:support_request) { nil }

      it "raises an error" do
        # xxx
      end

      it "sends error to rollbar" do
        # xxxx
      end
    end
  end

end
