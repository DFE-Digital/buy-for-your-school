require "rails_helper"

RSpec.describe StringSanitiser do
  describe "#call" do
    it "strips malicious tags from every value in a hash" do
      args = { key: "<script>alert('problem');</script>Some allowed text" }
      result = described_class.new(args:).call
      expect(result).to eq(key: "alert('problem');Some allowed text")
    end

    it "doesn't strip safe tags" do
      args = { key: "<p>paragraph</p><b>bold</b><i>italic</i>" }
      result = described_class.new(args:).call
      expect(result).to eq(key: "<p>paragraph</p><b>bold</b><i>italic</i>")
    end

    context "when the value is an Array" do
      it "strips malicious tags from every value of the array (only going 1 level deep)" do
        args = { key: ["<script>alert('problem');</script>Some allowed text", "<a href='evil.com'>Link</a>"] }
        result = described_class.new(args:).call
        expect(result).to eq(key: ["alert('problem');Some allowed text", "Link"])
      end

      context "when the array contains non string values" do
        it "doesn't raise an error" do
          date = Date.current
          args = { key: ["A string", date, 1] }

          result = described_class.new(args:).call

          expect(result).to eq(key: ["A string", date, 1])
        end
      end
    end

    context "when the value is a hash of more args" do
      it "strips malicious tags from every value in every hash" do
        args = {
          first_hash_key: {
            second_hash_key: "<script>alert('problem');</script>2",
            nested_hash: {
              third_hash_key: "<a href='evil.com'>Link</a>",
            },
          },
        }
        result = described_class.new(args:).call
        expect(result).to eq(
          first_hash_key: {
            second_hash_key: "alert('problem');2",
            nested_hash: {
              third_hash_key: "Link",
            },
          },
        )
      end
    end

    context "when the value is a Date" do
      it "returns the date without raising an error" do
        date = Date.current
        args = { key: date }

        result = described_class.new(args:).call

        expect(result).to eq(key: date)
      end
    end
  end
end
