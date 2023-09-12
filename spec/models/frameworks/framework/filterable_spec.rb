require "rails_helper"

describe Frameworks::Framework::Filterable do
  subject(:filterable) { Frameworks::Framework }

  describe "filtering" do
    subject(:filtering) { filterable.filtering(params) }

    let(:provider_1) { create(:frameworks_provider) }
    let(:provider_2) { create(:frameworks_provider) }
    let(:category_1) { create(:support_category) }
    let(:category_2) { create(:support_category) }
    let(:e_and_o_lead) { create(:support_agent) }
    let(:proc_ops_lead) { create(:support_agent) }

    before do
      create(:frameworks_framework, name: "DfE Approved - Provider 1", status: :dfe_approved, provider: provider_1, support_category: category_1)
      create(:frameworks_framework, name: "Not Approved - Provider 2", status: :not_approved, provider: provider_2, support_category: category_2)
      create(:frameworks_framework, name: "Cab Approved - Provider 1", status: :cab_approved, provider: provider_1, support_category: category_1)
      create(:frameworks_framework, name: "Evaluating - Provider 1", status: :evaluating, provider: provider_1, support_category: category_2, proc_ops_lead:)
      create(:frameworks_framework, name: "Evaluating - Provider 2", status: :evaluating, provider: provider_2, support_category: category_1, e_and_o_lead:)
    end

    describe "filtering by status" do
      let(:params) { { status: %w[dfe_approved] } }

      it "returns all frameworks matching the given statuses only" do
        expect(filtering.results.pluck(:name)).to match_array(["DfE Approved - Provider 1"])
      end
    end

    describe "filtering by provider" do
      let(:params) { { provider: [provider_1.id] } }

      it "returns all frameworks matching the given providers only" do
        expect(filtering.results.pluck(:name)).to match_array(["DfE Approved - Provider 1", "Cab Approved - Provider 1", "Evaluating - Provider 1"])
      end
    end

    describe "filtering by category" do
      let(:params) { { category: [category_2.id] } }

      it "returns all frameworks matching the given categories only" do
        expect(filtering.results.pluck(:name)).to match_array(["Not Approved - Provider 2", "Evaluating - Provider 1"])
      end
    end

    describe "filtering by e and o lead" do
      let(:params) { { e_and_o_lead: [e_and_o_lead.id] } }

      it "returns all frameworks matching the given agents only" do
        expect(filtering.results.pluck(:name)).to match_array(["Evaluating - Provider 2"])
      end
    end

    describe "filtering by proc ops lead" do
      let(:params) { { proc_ops_lead: [proc_ops_lead.id] } }

      it "returns all frameworks matching the given agents only" do
        expect(filtering.results.pluck(:name)).to match_array(["Evaluating - Provider 1"])
      end
    end
  end
end
