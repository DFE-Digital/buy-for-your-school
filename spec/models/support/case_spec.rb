RSpec.describe Support::Case, type: :model do
  subject(:support_case) { create(:support_case) }

  it { is_expected.to belong_to(:detected_category).class_name("Support::Category").optional }
  it { is_expected.to belong_to(:procurement_stage).class_name("Support::ProcurementStage").optional }

  it "belongs to a category" do
    expect(support_case.category).not_to be_nil
    expect(support_case.category.title).to match(/support category title \d/)
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
  it { is_expected.to define_enum_for(:state).with_values(%i[initial opened resolved on_hold closed pipeline no_response]) }
  it { is_expected.to define_enum_for(:source).with_values(%i[digital nw_hub sw_hub incoming_email faf engagement_and_outreach schools_commercial_team engagement_and_outreach_cms]) }

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
        "id,ref,category_id,request_text,support_level,status,state,created_at,updated_at,agent_id,first_name,last_name,email,phone_number,source,organisation_id,existing_contract_id,new_contract_id,procurement_id,savings_status,savings_estimate_method,savings_actual_method,savings_estimate,savings_actual,action_required,organisation_type,value,closure_reason,extension_number,other_category,other_query,procurement_amount,confidence_level,special_requirements,query_id,exit_survey_sent,detected_category_id,creation_source,user_selected_category,created_by_id,procurement_stage_id,initial_request_text,with_school,next_key_date,next_key_date_description,discovery_method,discovery_method_other_text,project,other_school_urns,is_evaluator,evaluation_due_date,has_uploaded_documents\n",
      )
    end
  end

  describe ".triage" do
    before do
      create(:support_case, support_level: :L1)
      create(:support_case, support_level: :L2)
      create(:support_case, support_level: :L3)
      create(:support_case, support_level: :L4)
      create(:support_case, support_level: :L5)
    end

    it "returns level 1, 2 and 3 cases" do
      expect(described_class.triage.map(&:support_level)).to match_array(%w[L1 L2 L3])
    end
  end

  describe ".high_level" do
    before do
      create(:support_case, support_level: :L1)
      create(:support_case, support_level: :L2)
      create(:support_case, support_level: :L3)
      create(:support_case, support_level: :L4)
      create(:support_case, support_level: :L5)
    end

    it "returns level 3, 4 and 5 cases" do
      expect(described_class.high_level.map(&:support_level)).to match_array(%w[L3 L4 L5])
    end
  end
end
