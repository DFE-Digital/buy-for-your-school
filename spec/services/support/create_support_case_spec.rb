RSpec.describe Support::CreateSupportCase do
  subject(:service) { described_class.new(support_enquiry) }

  let(:support_enquiry) { create(:support_enquiry) }
  let(:result) { service.call }

  describe "#call" do
    context "when a support enquiry is given" do
      let(:support_enquiry) { create(:support_enquiry) }

      it "creates a support case" do
        expect(result.ref).to eq "000001"
        expect(result.state).to eq "initial"
      end



      context "with documents" do
        let(:document) { create(:support_document, documentable: support_enquiry) }

        #xit "creates a support case with documents" do
          #xxx
        # end
      end
    end
  end
end
