require "rails_helper"

describe CaseHistory::HandleCaseStateChanges do
  subject(:handler) { described_class.new }

  before { define_basic_procurement_stages }

  describe "#agent_assigned_to_case" do
    let(:support_case_id) { create(:support_case).id }
    let(:assigned_by_agent_id) { create(:support_agent).id }
    let(:assigned_to_agent_id) { create(:support_agent).id }

    it "creates a case note for the assignment" do
      payload = { support_case_id:, assigned_by_agent_id:, assigned_to_agent_id: }
      expect { handler.agent_assigned_to_case(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.event_type).to eq("case_assigned")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.agent_id).to eq(assigned_by_agent_id)
      expect(interaction.additional_data["assigned_to_agent_id"]).to eq(assigned_to_agent_id)
    end
  end

  describe "#case_opened" do
    let(:support_case_id) { create(:support_case).id }
    let(:agent_id) { create(:support_agent).id }
    let(:reason) { "good_reason" }

    it "creates a case note for the case opening" do
      payload = { support_case_id:, agent_id:, reason: }
      expect { handler.case_opened(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.event_type).to eq("case_opened")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.agent_id).to eq(agent_id)
      expect(interaction.additional_data["triggered_by"]).to eq(reason)
    end
  end

  describe "#case_held_by_system" do
    let(:support_case_id) { create(:support_case).id }
    let(:reason) { "reason to be held" }

    it "creates a case note about on-hold status" do
      payload = { support_case_id:, reason: }
      expect { handler.case_held_by_system(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.event_type).to eq("state_change")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.body).to eq("Case placed on hold due to reason to be held")
    end
  end

  describe "#case_categorisation_changed" do
    let!(:cat_1) { create(:support_category, title: "Cat1") }
    let!(:cat_2) { create(:support_category, title: "Cat2") }
    let!(:query_1) { create(:support_query, title: "Query1") }
    let!(:query_2) { create(:support_query, title: "Query2") }
    let!(:agent_id) { create(:support_agent).id }

    context "when the category is changed" do
      let!(:support_case_id) { create(:support_case, category: cat_1).id }
      let(:payload) { { case_id: support_case_id, agent_id:, category_id: [cat_1.id, cat_2.id] } }

      it "creates a case note about the change in category" do
        expect { handler.case_categorisation_changed(payload) }.to change(Support::Interaction, :count).from(0).to(1)
        interaction = Support::Interaction.last
        expect(interaction.event_type).to eq("case_categorisation_changed")
        expect(interaction.case_id).to eq(support_case_id)
        expect(interaction.agent_id).to eq(agent_id)
        expect(interaction.additional_data).to eq({ "from" => cat_1.id, "to" => cat_2.id, "type" => "category" })
        expect(interaction.body).to eq("Categorisation change")
      end
    end

    context "when the query is changed" do
      let!(:support_case_id) { create(:support_case, query: query_1).id }
      let(:payload) { { case_id: support_case_id, agent_id:, query_id: [query_1.id, query_2.id] } }

      it "creates a case note about the change in query" do
        expect { handler.case_categorisation_changed(payload) }.to change(Support::Interaction, :count).from(0).to(1)
        interaction = Support::Interaction.last
        expect(interaction.event_type).to eq("case_categorisation_changed")
        expect(interaction.case_id).to eq(support_case_id)
        expect(interaction.agent_id).to eq(agent_id)
        expect(interaction.additional_data).to eq({ "from" => query_1.id, "to" => query_2.id, "type" => "query" })
        expect(interaction.body).to eq("Categorisation change")
      end
    end

    context "when a category has been removed in favour of a query" do
      let!(:support_case_id) { create(:support_case, category: cat_1).id }
      let(:payload) { { case_id: support_case_id, agent_id:, category_id: [cat_1.id, nil], query_id: [nil, query_1.id] } }

      it "creates a case note about the change from category to query" do
        expect { handler.case_categorisation_changed(payload) }.to change(Support::Interaction, :count).from(0).to(1)
        interaction = Support::Interaction.last
        expect(interaction.event_type).to eq("case_categorisation_changed")
        expect(interaction.case_id).to eq(support_case_id)
        expect(interaction.agent_id).to eq(agent_id)
        expect(interaction.additional_data).to eq({ "from" => cat_1.id, "to" => query_1.id, "type" => "category_to_query" })
        expect(interaction.body).to eq("Categorisation change")
      end
    end

    context "when a query has been removed in favour of a category" do
      let!(:support_case_id) { create(:support_case, query: query_2).id }
      let(:payload) { { case_id: support_case_id, agent_id:, query_id: [query_2.id, nil], category_id: [nil, cat_2.id] } }

      it "creates a case note about the change from query to category" do
        expect { handler.case_categorisation_changed(payload) }.to change(Support::Interaction, :count).from(0).to(1)
        interaction = Support::Interaction.last
        expect(interaction.event_type).to eq("case_categorisation_changed")
        expect(interaction.case_id).to eq(support_case_id)
        expect(interaction.agent_id).to eq(agent_id)
        expect(interaction.additional_data).to eq({ "from" => query_2.id, "to" => cat_2.id, "type" => "query_to_category" })
        expect(interaction.body).to eq("Categorisation change")
      end
    end
  end
end
