require "rails_helper"

describe Support::Case::Historyable do
  subject(:historyable) { create(:support_case) }

  let(:agent) { create(:support_agent) }

  around do |example|
    Current.set(agent:) do
      example.run
    end
  end

  describe "#add_note" do
    it "logs note in case history" do
      expect { historyable.add_note("My Note") }.to \
        change { Support::Interaction.note.where(agent:, case: historyable, body: "My Note").count }
        .from(0).to(1)
    end
  end

  describe "case callbacks" do
    context "when changing support level" do
      it "logs change in case history" do
        expect { historyable.update!(support_level: "L5") }.to \
          change { Support::Interaction.case_level_changed.where(agent:, case: historyable, body: "Support level change").count }
          .from(0).to(1)
      end
    end

    context "when changing procurement stage" do
      before { define_basic_procurement_stages }

      it "logs change in case history" do
        expect { historyable.update!(procurement_stage: tender_prep_stage) }.to \
          change { Support::Interaction.case_procurement_stage_changed.where(agent:, case: historyable, body: "Procurement stage change").count }
          .from(0).to(1)
      end
    end

    context "when changing 'with school' flag" do
      it "logs change in 'with school' flag" do
        expect { historyable.update!(with_school: true) }.to \
          change { Support::Interaction.case_with_school_changed.where(agent:, case: historyable, body: "'With School' flag change").count }
          .from(0).to(1)
      end
    end

    context "when changing the next key date" do
      it "logs change in next key date" do
        expect { historyable.update!(next_key_date: Date.parse("2023-09-15")) }.to \
          change { Support::Interaction.case_next_key_date_changed.where(agent:, case: historyable, body: "Next key date change").count }
          .from(0).to(1)
      end
    end

    context "when changing the next key date description" do
      it "logs change in next key date" do
        expect { historyable.update!(next_key_date_description: "key event") }.to \
          change { Support::Interaction.case_next_key_date_changed.where(agent:, case: historyable, body: "Next key date change").count }
          .from(0).to(1)
      end
    end

    context "when changing the source" do
      it "logs change in source" do
        expect { historyable.update!(source: :faf) }.to \
          change { Support::Interaction.state_change.where(agent:, case: historyable, body: "Source changed").count }
          .from(0).to(1)
      end
    end

    context "when changing the value" do
      it "logs change in value" do
        expect { historyable.update!(value: 1450.55) }.to \
          change { Support::Interaction.state_change.where(agent:, case: historyable, body: "Case value changed").count }
          .from(0).to(1)
      end
    end

    context "when changing the category or query" do
      before do
        define_basic_categories
        define_basic_queries
      end

      context "when changing the category" do
        it "logs change in category" do
          interaction = Support::Interaction.case_categorisation_changed.where(agent:, case: historyable, body: "Categorisation change")
          expect { historyable.update!(category: gas_category) }.to \
            change { interaction.count }.from(0).to(1)
          expect(interaction.first.additional_data["type"]).to eq("category")
        end
      end

      context "when changing the query" do
        it "logs change in query" do
          interaction = Support::Interaction.case_categorisation_changed.where(agent:, case: historyable, body: "Categorisation change")
          expect { historyable.update!(query: legal_query) }.to \
            change { interaction.count }.from(0).to(1)
          expect(interaction.first.additional_data["type"]).to eq("query")
        end
      end

      context "when changing from category to query" do
        subject(:historyable) { create(:support_case, category: gas_category) }

        it "logs change" do
          interaction = Support::Interaction.case_categorisation_changed.where(agent:, case: historyable, body: "Categorisation change")
          expect { historyable.update!(category: nil, query: legal_query) }.to \
            change { interaction.count }.from(0).to(1)
          expect(interaction.first.additional_data["type"]).to eq("category_to_query")
        end
      end

      context "when changing from query to category" do
        subject(:historyable) { create(:support_case, query: legal_query) }

        it "logs change" do
          interaction = Support::Interaction.case_categorisation_changed.where(agent:, case: historyable, body: "Categorisation change")
          expect { historyable.update!(query: nil, category: gas_category) }.to \
            change { interaction.count }.from(0).to(1)
          expect(interaction.first.additional_data["type"]).to eq("query_to_category")
        end
      end
    end
  end
end
