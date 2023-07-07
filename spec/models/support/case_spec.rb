RSpec.describe Support::Case, type: :model do
  subject(:support_case) { create(:support_case) }

  it { is_expected.to belong_to(:detected_category).class_name("Support::Category").optional }

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
        "id,ref,category_id,request_text,support_level,status,state,created_at,updated_at,agent_id,first_name,last_name,email,phone_number,source,organisation_id,existing_contract_id,new_contract_id,procurement_id,savings_status,savings_estimate_method,savings_actual_method,savings_estimate,savings_actual,action_required,organisation_type,value,closure_reason,extension_number,other_category,other_query,procurement_amount,confidence_level,special_requirements,query_id,exit_survey_sent,detected_category_id,creation_source,created_by_id,user_selected_category\n",
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

  describe "ordering" do
    before do
      cat_e = create(:support_category, title: "E-cat")
      create(:support_case, :opened, ref: "000500", action_required: true, organisation: create(:support_organisation, name: "A-org"), category: create(:support_category, title: "A-cat"), agent: create(:support_agent, first_name: "Avery", last_name: "Jones"))
      create(:support_case, :opened, ref: "000501", action_required: false, organisation: create(:support_organisation, name: "B-org"), category: create(:support_category, title: "B-cat"), agent: create(:support_agent, first_name: "Brooke", last_name: "Davis"))
      create(:support_case, :on_hold, ref: "000502", action_required: true, organisation: create(:support_establishment_group, name: "C-org"), category: create(:support_category, title: "C-cat"), agent: create(:support_agent, first_name: "Chloe", last_name: "Hernandez"))
      create(:support_case, :on_hold, ref: "000503", action_required: true, organisation: create(:support_establishment_group, name: "D-org"), category: create(:support_category, title: "D-cat"), agent: create(:support_agent, first_name: "Daisy", last_name: "Carter"))
      create(:support_case, :initial, ref: "000504", action_required: false, organisation: create(:support_organisation, name: "E-org"), category: cat_e, agent: create(:support_agent, first_name: "Emma", last_name: "Lee"))
      create(:support_case, :initial, ref: "000505", action_required: true, organisation: create(:support_organisation, name: "F-org"), category: cat_e, agent: create(:support_agent, first_name: "Faith", last_name: "Rodriguez"))
      create(:support_case, :closed, ref: "000506", action_required: false, organisation: create(:support_establishment_group, name: "G-org"), category: create(:support_category, title: "F-cat"), agent: create(:support_agent, first_name: "Grace", last_name: "Patel"))
      create(:support_case, :closed, ref: "000507", action_required: false, organisation: create(:support_organisation, name: "H-org"), category: create(:support_category, title: "G-cat"), agent: create(:support_agent, first_name: "Harper", last_name: "Sims"))
      create(:support_case, :resolved, ref: "000508", action_required: false, organisation: create(:support_organisation, name: "I-org"), category: create(:support_category, title: "H-cat"), agent: create(:support_agent, first_name: "Harper", last_name: "Kim"))
      create(:support_case, :resolved, ref: "000509", action_required: true, organisation: create(:support_establishment_group, name: "I-org"), category: create(:support_category, title: "I-cat"), agent: create(:support_agent, first_name: "Isabella", last_name: "Singh"))
    end

    describe ".order_by_action" do
      context "when descending" do
        let(:order) { "DESC" }

        it "is ordered correctly" do
          # Cases are listed in the following order:
          # - Action
          # - New / Initial
          # - Open
          # - On hold
          # - Resolved
          # - Everything else

          results = described_class.order_by_action(order).pluck(:ref)

          expect(results).to eq(%w[000505 000500 000503 000502 000509 000504 000501 000508 000507 000506])
        end
      end

      context "when ascending" do
        let(:order) { "ASC" }

        it "is ordered correctly" do
          # Cases are listed in the following order:
          # - Everything else
          # - Resolved
          # - On hold
          # - Open
          # - New / Initial
          # - Action

          results = described_class.order_by_action(order).pluck(:ref)

          expect(results).to eq(%w[000504 000501 000508 000507 000506 000505 000500 000503 000502 000509])
        end
      end
    end

    describe ".order_by_ref" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = described_class.order_by_ref(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000507 000508 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = described_class.order_by_ref(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".order_by_organisation_name" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = described_class.order_by_organisation_name(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000507 000509 000508
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = described_class.order_by_organisation_name(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".order_by_subcategory" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = described_class.order_by_subcategory(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000505 000504 000506 000507 000508 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = described_class.order_by_subcategory(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".order_by_agent" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = described_class.order_by_agent(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000508 000507 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = described_class.order_by_agent(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000507 000508 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".order_by_last_updated" do
      context "without interactions" do
        context "when ascending" do
          let(:order) { "ASC" }

          it "sorts in ascending order" do
            results = described_class.order_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000500 000501 000502 000503 000504 000505 000506 000507 000508 000509
            ])
          end
        end

        context "when descending" do
          let(:order) { "DESC" }

          it "sorts in descending order" do
            results = described_class.order_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
            ])
          end
        end
      end

      context "with interactions" do
        before do
          create(:support_interaction, case: described_class.find_by(ref: "000503"))
          create(:support_interaction, case: described_class.find_by(ref: "000505"))
        end

        context "when ascending" do
          let(:order) { "ASC" }

          it "sorts in ascending order" do
            results = described_class.order_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000500 000501 000502 000504 000506 000507 000508 000509 000503 000505
            ])
          end
        end

        context "when descending" do
          let(:order) { "DESC" }

          it "sorts in descending order" do
            results = described_class.order_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000505 000503 000509 000508 000507 000506 000504 000502 000501 000500
            ])
          end
        end
      end
    end

    describe ".order_by_received" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = described_class.order_by_received(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000507 000508 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = described_class.order_by_received(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".order_by_state" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = described_class.order_by_state(order).pluck(:ref)
          expect(results).to eq(%w[
            000507 000506 000509 000508 000503 000502 000501 000500 000505 000504
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = described_class.order_by_state(order).pluck(:ref)
          expect(results).to eq(%w[
            000505 000504 000501 000500 000503 000502 000509 000508 000507 000506
          ])
        end
      end
    end
  end
end
