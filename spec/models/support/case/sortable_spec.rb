require "rails_helper"

describe Support::Case::Sortable do
  describe ".sorted_by" do
    it "takes the given field and sort order and calls the named scope for that field" do
      ascending_result = double("ascending_result")
      descending_result = double("descending_result")

      allow(Support::Case).to receive(:sort_by_last_updated).with("ASC").and_return(ascending_result)
      allow(Support::Case).to receive(:sort_by_last_updated).with("DESC").and_return(descending_result)

      expect(Support::Case.sorted_by(sort: { last_updated: "ascending" })).to eq(ascending_result)
      expect(Support::Case.sorted_by(sort: { last_updated: "descending" })).to eq(descending_result)
      expect(Support::Case.sorted_by(sort_by: "last_updated", sort_order: "ascending")).to eq(ascending_result)
      expect(Support::Case.sorted_by(sort_by: "last_updated", sort_order: "descending")).to eq(descending_result)
    end
  end

  describe "scopes" do
    before do
      cat_e = create(:support_category, title: "E-cat")
      create(:support_case, :opened, ref: "000500", action_required: true, value: 14_504.22, organisation: create(:support_organisation, name: "A-org"), category: create(:support_category, title: "A-cat"), agent: create(:support_agent, first_name: "Avery", last_name: "Jones"))
      create(:support_case, :opened, ref: "000501", action_required: false, value: 26.99, organisation: create(:support_organisation, name: "B-org"), category: create(:support_category, title: "B-cat"), agent: create(:support_agent, first_name: "Brooke", last_name: "Davis"))
      create(:support_case, :on_hold, ref: "000502", action_required: true, value: 56_228.00, organisation: create(:support_establishment_group, name: "C-org"), category: create(:support_category, title: "C-cat"), agent: create(:support_agent, first_name: "Chloe", last_name: "Hernandez"))
      create(:support_case, :on_hold, ref: "000503", action_required: true, value: 50_000.40, organisation: create(:support_establishment_group, name: "D-org"), category: create(:support_category, title: "D-cat"), agent: create(:support_agent, first_name: "Daisy", last_name: "Carter"))
      create(:support_case, :initial, ref: "000504", action_required: false, value: 576.50, organisation: create(:support_organisation, name: "E-org"), category: cat_e, agent: create(:support_agent, first_name: "Emma", last_name: "Lee"))
      create(:support_case, :initial, ref: "000505", action_required: true, value: 1_034.05, organisation: create(:support_organisation, name: "F-org"), category: cat_e, agent: create(:support_agent, first_name: "Faith", last_name: "Rodriguez"))
      create(:support_case, :closed, ref: "000506", action_required: false, value: 900.00, organisation: create(:support_establishment_group, name: "G-org"), category: create(:support_category, title: "F-cat"), agent: create(:support_agent, first_name: "Grace", last_name: "Patel"))
      create(:support_case, :closed, ref: "000507", action_required: false, value: 125_899.00, organisation: create(:support_organisation, name: "H-org"), category: create(:support_category, title: "G-cat"), agent: create(:support_agent, first_name: "Harper", last_name: "Sims"))
      create(:support_case, :resolved, ref: "000508", action_required: false, value: nil, organisation: create(:support_organisation, name: "I-org"), category: create(:support_category, title: "H-cat"), agent: create(:support_agent, first_name: "Harper", last_name: "Kim"))
      create(:support_case, :resolved, ref: "000509", action_required: true, value: 2.50, organisation: create(:support_establishment_group, name: "I-org"), category: create(:support_category, title: "I-cat"), agent: create(:support_agent, first_name: "Isabella", last_name: "Singh"))
    end

    describe ".sort_by_action" do
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

          results = Support::Case.sort_by_action(order).pluck(:ref)

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

          results = Support::Case.sort_by_action(order).pluck(:ref)

          expect(results).to eq(%w[000504 000501 000508 000507 000506 000505 000500 000503 000502 000509])
        end
      end
    end

    describe ".sort_by_ref" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_ref(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000507 000508 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_ref(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".sort_by_organisation_name" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_organisation_name(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000507 000509 000508
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_organisation_name(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".sort_by_subcategory" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_subcategory(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000505 000504 000506 000507 000508 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_subcategory(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".sort_by_agent" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_agent(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000508 000507 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_agent(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000507 000508 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".sort_by_last_updated" do
      context "without interactions" do
        context "when ascending" do
          let(:order) { "ASC" }

          it "sorts in ascending order" do
            results = Support::Case.sort_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000500 000501 000502 000503 000504 000505 000506 000507 000508 000509
            ])
          end
        end

        context "when descending" do
          let(:order) { "DESC" }

          it "sorts in descending order" do
            results = Support::Case.sort_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
            ])
          end
        end
      end

      context "with interactions" do
        before do
          create(:support_interaction, case: Support::Case.find_by(ref: "000503"))
          create(:support_interaction, case: Support::Case.find_by(ref: "000505"))
        end

        context "when ascending" do
          let(:order) { "ASC" }

          it "sorts in ascending order" do
            results = Support::Case.sort_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000500 000501 000502 000504 000506 000507 000508 000509 000503 000505
            ])
          end
        end

        context "when descending" do
          let(:order) { "DESC" }

          it "sorts in descending order" do
            results = Support::Case.sort_by_last_updated(order).map(&:ref)
            expect(results).to eq(%w[
              000505 000503 000509 000508 000507 000506 000504 000502 000501 000500
            ])
          end
        end
      end
    end

    describe ".sort_by_received" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_received(order).pluck(:ref)
          expect(results).to eq(%w[
            000500 000501 000502 000503 000504 000505 000506 000507 000508 000509
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_received(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000508 000507 000506 000505 000504 000503 000502 000501 000500
          ])
        end
      end
    end

    describe ".sort_by_state" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_state(order).pluck(:ref)
          expect(results).to eq(%w[
            000507 000506 000509 000508 000503 000502 000501 000500 000505 000504
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_state(order).pluck(:ref)
          expect(results).to eq(%w[
            000505 000504 000501 000500 000503 000502 000509 000508 000507 000506
          ])
        end
      end
    end

    describe ".sort_by_value" do
      context "when ascending" do
        let(:order) { "ASC" }

        it "sorts in ascending order" do
          results = Support::Case.sort_by_value(order).pluck(:ref)
          expect(results).to eq(%w[
            000509 000501 000504 000506 000505 000500 000503 000502 000507 000508
          ])
        end
      end

      context "when descending" do
        let(:order) { "DESC" }

        it "sorts in descending order" do
          results = Support::Case.sort_by_value(order).pluck(:ref)
          expect(results).to eq(%w[
            000508 000507 000502 000503 000500 000505 000506 000504 000501 000509
          ])
        end
      end
    end
  end
end
