RSpec.describe Support::Case, type: :model do
  subject(:support_case) { create(:support_case) }

  it "belongs to a category" do
    expect(support_case.category).not_to be_nil
    expect(support_case.category.title).to match /support category title \d/
  end

  context "with documents" do
    let!(:document) { create(:support_document, case: support_case) }

    it "has document returned in collection" do
      expect(support_case.documents).not_to be_empty
      expect(support_case.documents.first.document_body).to eql document.document_body
    end
  end

  it { is_expected.to define_enum_for(:support_level).with_values(%i[L1 L2 L3 L4 L5]) }
  it { is_expected.to define_enum_for(:state).with_values(%i[initial open resolved pending closed pipeline no_response]) }

  describe "#generate_ref" do
    context "when no cases exist" do
      it "generates a reference starting at 1" do
        expect(support_case.ref).to eql "000001"
      end
    end

    context "when cases already exist" do
      before do
        create_list(:support_case, 10)
      end

      let!(:new_case) { create(:support_case) }

      it "generates an incrementing reference" do
        expect(new_case.ref).to eql "000011"
      end
    end
  end
end
