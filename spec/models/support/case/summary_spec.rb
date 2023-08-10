require "rails_helper"

describe Support::Case::Summary do
  subject(:summary) { described_class.new(params) }

  let(:request_type) { true }
  let(:category_id) { gas_category.id }
  let(:query_id) { nil }
  let(:other_category) { nil }
  let(:other_query) { nil }
  let(:source) { :faf }
  let(:value) { nil }

  let(:params) { { request_type:, category_id:, query_id:, other_category:, other_query:, source:, value: } }

  before do
    define_basic_categories
    define_basic_queries
  end

  describe "validation" do
    describe "category validation" do
      context "when request_type is true (a procurement request)" do
        let(:request_type) { true }

        context "and a category is not selected" do
          let(:category_id) { nil }

          it "invalidates the model due to missing category" do
            expect(summary).not_to be_valid
            expect(summary.errors.messages[:category_id]).to eq ["Please select a procurement category"]
          end
        end
      end
    end

    describe "query validation" do
      context "when request_type is false (a non-procurement request)" do
        let(:request_type) { false }

        context "and a query is not selected" do
          let(:query_id) { nil }

          it "invalidates the model due to missing query" do
            expect(summary).not_to be_valid
            expect(summary.errors.messages[:query_id]).to eq ["Please select a query category"]
          end
        end
      end
    end

    describe "other category validation" do
      context "when Other (General) category is selected" do
        let(:category_id) { Support::Category.find_by(title: "Other (General)").id }

        context "and other_category is not provided" do
          let(:other_category) { nil }

          it "invalidates the model due to missing other_category" do
            expect(summary).not_to be_valid
            expect(summary.errors.messages[:other_category]).to eq ["Enter the procurement category"]
          end
        end
      end
    end

    describe "other query validation" do
      context "when Other query is selected" do
        let(:query_id) { Support::Query.find_by(title: "Other").id }

        context "and other_query is not provided" do
          let(:other_query) { nil }

          it "invalidates the model due to missing other_query" do
            expect(summary).not_to be_valid
            expect(summary.errors.messages[:other_query]).to eq ["Enter the type of query"]
          end
        end
      end
    end

    describe "source validation" do
      context "when the source is not provided" do
        let(:source) { nil }

        it "invalidates the model due to missing source" do
          expect(summary).not_to be_valid
          expect(summary.errors.messages[:source]).to eq ["Select the source of the case"]
        end
      end
    end

    describe "value validation" do
      context "when the value is provided" do
        context "and it is non-numeric" do
          let(:value) { "abc" }

          it "invalidates the model due to invalid value" do
            expect(summary).not_to be_valid
            expect(summary.errors.messages[:value]).to eq ["Enter a number"]
          end
        end
      end
    end
  end
end
