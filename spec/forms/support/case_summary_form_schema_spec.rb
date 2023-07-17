RSpec.describe Support::CaseSummaryFormSchema do
  subject(:schema) { described_class.new.call(**values) }

  before do
    define_basic_categories
    allow(Support::Category).to receive(:other_category_id).and_return(1)
    allow(Support::Query).to receive(:other_query_id).and_return(2)
  end

  describe "validates source" do
    let(:values) do
      { source:, request_type: true, category_id: gas_category.id }
    end

    context "when the source value is provided" do
      let(:source) { "incoming_email" }

      it "does not raise a validation error" do
        expect(schema.errors.messages.size).to eq 0
      end
    end

    context "when the source value is not provided" do
      let(:source) { nil }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "Select the source of the case"
      end
    end
  end

  describe "other category text value" do
    context "when other category is selected" do
      context "but other text box is not filled in" do
        let(:values) { { category_id: 1, other_category: "" } }

        it "gives a validation error for other_category" do
          error_message = schema.errors.messages.find { |x| x.path == [:other_category] }
          expect(error_message.text).to eq("Enter the procurement category")
        end
      end
    end
  end

  describe "other query text value" do
    context "when other query is selected" do
      context "but other text box is not filled in" do
        let(:values) { { query_id: 2, other_query: "" } }

        it "gives a validation error for other_query" do
          error_message = schema.errors.messages.find { |x| x.path == [:other_query] }
          expect(error_message.text).to eq("Enter the type of query")
        end
      end
    end
  end

  describe "non procurement query value" do
    context "when request type is non procurement" do
      context "but a query has not been selected" do
        let(:values) { { request_type: false, query_id: "" } }

        it "gives a validation error for query_id" do
          error_message = schema.errors.messages.find { |x| x.path == [:query_id] }
          expect(error_message.text).to eq("Please select a query category")
        end
      end
    end
  end
end
