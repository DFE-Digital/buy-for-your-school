require "rails_helper"

RSpec.describe I18n::Backend::Contentful do
  describe ".flatten_translations" do
    context "when given a nested hash" do
      it "flattens a simple nested hash" do
        nested_hash = { en: { service_name: "FABS" } }
        expected_flat_hash = { "en.service_name" => "FABS" }

        result = described_class.flatten_translations(nested_hash)
        expect(result).to eq(expected_flat_hash)
      end

      it "flattens a deeply nested hash" do
        nested_hash = { en: { date: { formats: { standard: "%d %B %Y" } } } }
        expected_flat_hash = { "en.date.formats.standard" => "%d %B %Y" }

        result = described_class.flatten_translations(nested_hash)
        expect(result).to eq(expected_flat_hash)
      end
    end

    context "when given an empty hash" do
      it "returns an empty hash" do
        result = described_class.flatten_translations({})
        expect(result).to eq({})
      end
    end
  end

  describe ".unflatten_translations" do
    context "when given a flat hash with translations" do
      it "unflattens a simple flat hash" do
        flat_entries = [
          { fields: { key: "en.service_name", value: "FABS" } },
          { fields: { key: "en.date.formats.standard", value: "%d %B %Y" } },
        ]
        expected_nested_hash = {
          en: {
            service_name: "FABS",
            date: {
              formats: {
                standard: "%d %B %Y",
              },
            },
          },
          "en.date.formats.standard": "%d %B %Y",
          "en.service_name": "FABS",
        }

        flat_entries.each { |entry| entry.define_singleton_method(:fields) { self[:fields] } }
        result = described_class.unflatten_translations(flat_entries)
        expect(result).to eq(expected_nested_hash)
      end

      it "unflattens a deeply nested flat hash" do
        flat_entries = [
          { fields: { key: "en.date.formats.standard", value: "%d %B %Y" } },
          { fields: { key: "en.date.formats.short", value: "%d/%m/%y" } },
        ]
        expected_nested_hash = {
          en: {
            date: {
              formats: {
                standard: "%d %B %Y",
                short: "%d/%m/%y",
              },
            },
          },
          "en.date.formats.standard": "%d %B %Y",
          "en.date.formats.short": "%d/%m/%y",
        }

        flat_entries.each { |entry| entry.define_singleton_method(:fields) { self[:fields] } }
        result = described_class.unflatten_translations(flat_entries)
        expect(result).to eq(expected_nested_hash)
      end
    end

    context "when given an empty array of entries" do
      it "returns a hash with default date formats" do
        result = described_class.unflatten_translations([])

        expect(result).to eq(
          en: {
            date: {
              formats: {
                standard: "%d %B %Y",
              },
            },
          },
          "en.date.formats.standard": "%d %B %Y",
        )
      end
    end

    context "when some entries are missing standard date formats" do
      it "adds default date formats" do
        flat_entries = [
          { fields: { key: "en.service_name", value: "FABS" } },
        ]
        expected_nested_hash = {
          en: {
            service_name: "FABS",
            date: {
              formats: {
                standard: "%d %B %Y",
              },
            },
          },
          "en.date.formats.standard": "%d %B %Y",
          "en.service_name": "FABS",
        }

        flat_entries.each { |entry| entry.define_singleton_method(:fields) { self[:fields] } }
        result = described_class.unflatten_translations(flat_entries)
        expect(result).to eq(expected_nested_hash)
      end
    end
  end
end
