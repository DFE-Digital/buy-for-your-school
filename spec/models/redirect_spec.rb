require "rails_helper"

RSpec.describe Redirect, type: :model do
  describe "#initialize" do
    subject(:redirect) { described_class.new(entry) }

    let(:entry) do
      OpenStruct.new(
        id: "redirect-id",
        fields: {
          title: "Legacy category IT",
          source_path: "/categories/it/*",
          destination_path: "/categories/ict-business-systems/*",
          redirect_type: "permanent",
        },
      )
    end

    it "sets the attributes" do
      expect(redirect).to have_attributes(
        id: "redirect-id",
        title: "Legacy category IT",
        source_path: "/categories/it/*",
        destination_path: "/categories/ict-business-systems/*",
        redirect_type: "permanent",
      )
    end
  end

  describe ".all" do
    subject(:redirects) { described_class.all }

    let(:entry_a) do
      OpenStruct.new(
        id: "redirect-a",
        fields: {
          title: "About this service",
          source_path: "/about-this-service",
          destination_path: "/about-our-service",
          redirect_type: "permanent",
        },
      )
    end

    let(:entry_b) do
      OpenStruct.new(
        id: "redirect-b",
        fields: {
          title: "Legacy category IT",
          source_path: "/categories/it/*",
          destination_path: "/categories/ict-business-systems/*",
          redirect_type: "permanent",
        },
      )
    end

    before do
      allow(ContentfulClient).to receive(:entries).with(
        content_type: "redirect",
        select: described_class::SELECT_FIELDS,
        order: "fields.title",
      ).and_return([entry_a, entry_b])
    end

    it "fetches redirects from Contentful" do
      expect(redirects).to all(be_a(described_class))
    end
  end

  describe "#permanent?" do
    it "returns true for permanent redirects" do
      redirect = described_class.new(
        OpenStruct.new(id: "1", fields: { title: "Test", source_path: "/a", destination_path: "/b", redirect_type: "permanent" }),
      )

      expect(redirect).to be_permanent
      expect(redirect).not_to be_temporary
    end
  end

  describe "#temporary?" do
    it "returns true for temporary redirects" do
      redirect = described_class.new(
        OpenStruct.new(id: "1", fields: { title: "Test", source_path: "/a", destination_path: "/b", redirect_type: "temporary" }),
      )

      expect(redirect).to be_temporary
      expect(redirect).not_to be_permanent
    end
  end
end
