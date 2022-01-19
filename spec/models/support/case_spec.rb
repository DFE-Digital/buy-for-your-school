RSpec.describe Support::Case, type: :model do
  subject(:support_case) { create(:support_case) }

  it "belongs to a category" do
    expect(support_case.category).not_to be_nil
    expect(support_case.category.title).to match /support category title \d/
  end

  it "has optional new and existing contracts" do
    expect(support_case).to belong_to(:new_contract).optional
    expect(support_case).to belong_to(:existing_contract).optional
  end

  it "belongs to an optional procurement" do
    expect(support_case).to belong_to(:procurement).optional
  end

  context "with documents" do
    let!(:document) { create(:support_document, case: support_case) }

    it "has document returned in collection" do
      expect(support_case.documents).not_to be_empty
      expect(support_case.documents.first.document_body).to eql document.document_body
    end
  end

  it { is_expected.to define_enum_for(:support_level).with_values(%i[L1 L2 L3 L4 L5]) }
  it { is_expected.to define_enum_for(:state).with_values(%i[initial opened resolved pending closed pipeline no_response]) }

  describe "#generate_ref" do
    context "when no cases exist" do
      it "generates a reference starting at 1" do
        expect(support_case.ref).to eql "000001"
      end

      it "only generates a reference if none already exists" do
        support_case.save!
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

  describe "#to_csv" do
    it "includes headers" do
      expect(described_class.to_csv).to eql(
        "id,ref,category_id,request_text,support_level,status,state,created_at,updated_at,agent_id,first_name,last_name,email,phone_number,source,organisation_id,existing_contract_id,new_contract_id,savings_status,savings_estimate_method,savings_actual_method,savings_estimate,savings_actual,action_required,procurement_id\n",
      )
    end
  end
end
