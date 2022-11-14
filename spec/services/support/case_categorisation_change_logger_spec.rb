require "spec_helper"

describe Support::CaseCategorisationChangeLogger do
  subject(:logger) { described_class.new(support_case:, agent_id:) }

  let(:agent_id)   { "Agent1" }

  describe "logging the change" do
    let(:previous_changes) { {} }
    let(:support_case)     { double("support_case", previous_changes:, log_categorisation_change: true) }

    before { logger.log! }

    context "when a category has been removed in favour of a query" do
      let(:previous_changes) { { category_id: ["Cat1", nil], query_id: [nil, "Query1"] } }

      it "logs as category_to_query" do
        expect(support_case).to have_received(:log_categorisation_change)
          .with(from: "Cat1", to: "Query1", type: :category_to_query)
      end
    end

    context "when a query has been removed in favour of a category" do
      let(:previous_changes) { { category_id: [nil, "Cat1"], query_id: ["Query1", nil] } }

      it "logs as query_to_category" do
        expect(support_case).to have_received(:log_categorisation_change)
          .with(from: "Query1", to: "Cat1", type: :query_to_category)
      end
    end

    context "when categories change" do
      let(:previous_changes) { { category_id: %w[Cat1 Cat2] } }

      it "logs as query_to_category" do
        expect(support_case).to have_received(:log_categorisation_change)
          .with(from: "Cat1", to: "Cat2", type: :category)
      end
    end

    context "when queries change" do
      let(:previous_changes) { { query_id: %w[Query1 Query2] } }

      it "logs as query_to_category" do
        expect(support_case).to have_received(:log_categorisation_change)
          .with(from: "Query1", to: "Query2", type: :query)
      end
    end

    context "when something else changes" do
      let(:previous_changes) { { no_such_id: [nil, "IgnoreMe"] } }

      it "does not log at all" do
        expect(support_case).not_to have_received(:log_categorisation_change)
      end
    end
  end
end
