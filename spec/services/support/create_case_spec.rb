RSpec.describe Support::CreateCase do
  subject(:service) { described_class.new(enquiry) }

  let(:result) { service.call }

  before do
    create(:support_category, :catering_support_category)
  end

  describe "#call" do
    context "when an enquiry is given" do
      let(:enquiry) { create(:support_enquiry) }

      it "opens a case" do
        expect(result.ref).to eq "000001"
        expect(result.state).to eq "initial"
      end

      context "with documents" do
        let(:enquiry) { create(:support_enquiry, :with_documents, document_count: 4) }

        it "opens a case with documents" do
          expect(result.documents.count).to eq 4
        end
      end
    end
  end
end
