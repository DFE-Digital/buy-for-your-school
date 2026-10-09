require "rails_helper"

RSpec.describe ContentfulAttachment do
  subject(:attachment) { described_class.new(entry) }

  let(:title) { "Energy guide" }
  let(:url) { "//assets.ctfassets.net/space/asset/energy-guide.pdf" }
  let(:file) { OpenStruct.new(file_name: "energy-guide.pdf", details: { "size" => 245_760 }) }
  let(:page_count) { "12" }
  let(:asset) { OpenStruct.new(title:, description: "How to switch supplier", url:, file:) }
  let(:entry) { OpenStruct.new(fields: { page_count:, attachment: asset }) }

  it "exposes the asset title and description" do
    expect(attachment).to have_attributes(title: "Energy guide", description: "How to switch supplier")
  end

  context "when the entry has no asset" do
    let(:asset) { nil }

    it "returns nil for the title and description" do
      expect(attachment).to have_attributes(title: nil, description: nil)
    end
  end

  describe "#page_count" do
    it "returns the page count as an integer" do
      expect(attachment.page_count).to eq(12)
    end

    context "when the page count is blank" do
      let(:page_count) { nil }

      it "returns nil" do
        expect(attachment.page_count).to be_nil
      end
    end
  end

  describe "#url" do
    it "adds https to protocol-relative Contentful URLs" do
      expect(attachment.url).to eq("https://assets.ctfassets.net/space/asset/energy-guide.pdf")
    end

    context "when the URL already has a protocol" do
      let(:url) { "https://example.com/energy-guide.pdf" }

      it "leaves it unchanged" do
        expect(attachment.url).to eq("https://example.com/energy-guide.pdf")
      end
    end

    context "when the entry has no asset" do
      let(:asset) { nil }

      it "returns nil" do
        expect(attachment.url).to be_nil
      end
    end
  end

  describe "#file_name" do
    it "returns the asset's file name" do
      expect(attachment.file_name).to eq("energy-guide.pdf")
    end

    context "when the asset has no file" do
      let(:file) { nil }

      it "returns nil" do
        expect(attachment.file_name).to be_nil
      end
    end
  end

  describe "#file_size" do
    it "returns the size in bytes" do
      expect(attachment.file_size).to eq(245_760)
    end

    context "when the asset has no file" do
      let(:file) { nil }

      it "returns nil" do
        expect(attachment.file_size).to be_nil
      end
    end
  end

  describe "#file_type" do
    it "returns the upper-cased file extension" do
      expect(attachment.file_type).to eq("PDF")
    end

    context "when the file name has no extension" do
      let(:file) { OpenStruct.new(file_name: "energy-guide", details: {}) }

      it "returns nil" do
        expect(attachment.file_type).to be_nil
      end
    end
  end

  describe "#link_text" do
    it "uses the title" do
      expect(attachment.link_text).to eq("Energy guide")
    end

    context "when the title is blank" do
      let(:title) { "" }

      it "falls back to the file name" do
        expect(attachment.link_text).to eq("energy-guide.pdf")
      end
    end

    context "when there is no title or file name" do
      let(:title) { nil }
      let(:file) { nil }

      it "uses a generic label" do
        expect(attachment.link_text).to eq("Download file")
      end
    end
  end
end
