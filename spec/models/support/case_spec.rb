RSpec.describe Support::Case, type: :model do
  subject(:support_case) { create(:support_case) }

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
  it { is_expected.to define_enum_for(:source).with_values(%i[digital nw_hub sw_hub incoming_email faf engagement_and_outreach schools_commercial_team]) }

  describe "#reopen_due_to_email" do
    context "when the has been resolved" do
      subject(:support_case) { create(:support_case, :resolved) }

      it "reopens the case" do
        support_case.reopen_due_to_email
        expect(support_case.reload).to be_opened
      end

      it "logs this reopening in case history" do
        support_case.reopen_due_to_email
        expect(support_case.interactions.last.event_type).to eq("state_change")
        expect(support_case.interactions.last.body).to eq("Case reopened due to receiving a new email.")
      end
    end
  end

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
        "id,ref,category_id,request_text,support_level,status,state,created_at,updated_at,agent_id,first_name,last_name,email,phone_number,source,organisation_id,existing_contract_id,new_contract_id,procurement_id,savings_status,savings_estimate_method,savings_actual_method,savings_estimate,savings_actual,action_required,organisation_type,value,closure_reason,extension_number,other_category,other_query,procurement_amount,confidence_level,special_requirements,query_id,exit_survey_sent,detected_category_id\n",
      )
    end
  end

  describe ".priority_ordering" do
    it "is ordered correctly" do
      # Cases are listed in the following order:
      # - Action
      # - New / Initial
      # - Open
      # - On hold
      # - Resolved
      # - Everything else

      create(:support_case, ref: "000500", action_required: true,  state: :initial)
      create(:support_case, ref: "000501", action_required: false, state: :initial)
      create(:support_case, ref: "000502", action_required: false, state: :resolved)
      create(:support_case, ref: "000503", action_required: false, state: :resolved)
      create(:support_case, ref: "000504", action_required: false, state: :opened)
      create(:support_case, ref: "000505", action_required: false, state: :opened)
      create(:support_case, ref: "000506", action_required: false, state: :on_hold)
      create(:support_case, ref: "000507", action_required: false, state: :on_hold)
      create(:support_case, ref: "000508", action_required: false, state: :closed)
      create(:support_case, ref: "000509", action_required: true,  state: :closed)

      results = described_class.priority_ordering.pluck(:ref)

      expect(results).to eq(%w[000509 000500 000501 000505 000504 000507 000506 000503 000502 000508])
    end
  end
end
