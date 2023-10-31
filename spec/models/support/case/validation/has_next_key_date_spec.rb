require "rails_helper"

describe Validation::HasNextKeyDate do
  subject(:has_next_key_date) { Support::Case::QuickEditor.new(params) }

  let(:next_key_date) { nil }
  let(:next_key_date_description) { nil }

  let(:params) { { next_key_date:, next_key_date_description: } }

  describe "validation" do
    describe "next key date validation" do
      context "when the next key date is provided" do
        context "and it is an invalid date" do
          let(:next_key_date) { { "year" => "2023", "month" => "13", "day" => "first" } }

          it "invalidates the model due to the invalid date" do
            expect(has_next_key_date).not_to be_valid
            expect(has_next_key_date.errors.messages[:next_key_date]).to eq ["Provide a valid date"]
          end
        end
      end

      context "when the next key date is not provided" do
        let(:next_key_date) { nil }

        context "and the next key date description is provided" do
          let(:next_key_date_description) { "key event" }

          it "invalidates the model due to the next key date description without a date" do
            expect(has_next_key_date).not_to be_valid
            expect(has_next_key_date.errors.messages[:next_key_date]).to eq ["Enter a date for the description"]
          end
        end
      end
    end
  end
end
