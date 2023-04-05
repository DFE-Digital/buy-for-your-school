require "rails_helper"

describe Support::CreateCaseFormSchema do
  subject(:schema) { described_class.new.call(**values) }

  before do
    allow(Support::Category).to receive(:other_category_id).and_return(1)
    allow(Support::Query).to receive(:other_query_id).and_return(2)
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

  describe "procurement_amount" do
    let(:validator) { double("validator") }

    before do
      allow(Support::Forms::ValidateProcurementAmount).to receive(:new).and_return(validator)
    end

    context "when the amount is invalid" do
      let(:values) { { procurement_amount: "abc" } }

      before do
        allow(validator).to receive(:invalid_number?).and_return(true)
        allow(validator).to receive(:too_large?).and_return(false)
      end

      it "gives a validation error for procurement_amount" do
        error_message = schema.errors.messages.find { |x| x.path == [:procurement_amount] }

        expect(error_message.text).to eq("Enter a valid number")
        expect(validator).to have_received(:invalid_number?).once
      end
    end

    context "when the amount is too large" do
      let(:values) { { procurement_amount: "10000000" } }

      before do
        allow(validator).to receive(:invalid_number?).and_return(false)
        allow(validator).to receive(:too_large?).and_return(true)
      end

      it "gives a validation error for procurement_amount" do
        error_message = schema.errors.messages.find { |x| x.path == [:procurement_amount] }

        expect(error_message.text).to eq("The amount cannot be larger than 9,999,999.99")
        expect(validator).to have_received(:too_large?).once
      end
    end
  end
end
