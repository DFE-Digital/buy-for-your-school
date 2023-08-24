require "rails_helper"

describe Frameworks::Framework::FafImportable do
  describe ".import_from_faf" do
    subject(:frameworks) { Frameworks::Framework }

    let(:framework_data) do
      OpenStruct.new(
        name: "Books, stationery and education supplies",
        provider_reference: "books",
        provider_name: "Super Books LTD",
        provider_url: "https://my.framework.com",
        ends_at: 2.weeks.from_now,
        description: "Description of books"
      )
    end

    it "creates frameworks with a status of dfe_approved already set" do
      frameworks.import_from_faf(framework_data)
      expect(Frameworks::Framework.all.all?(&:dfe_approved?)).to eq(true)
      expect(Frameworks::Framework.all.all?(&:published_on_faf?)).to eq(true)
    end

    context "when the Framework already exists for the given provider_reference" do
      let!(:existing_framework) { create(:frameworks_framework, provider_reference: "books") }

      it "updates the Framework details only" do
        frameworks.import_from_faf(framework_data)

        existing_framework.reload
        expect(existing_framework.provider_url).to eq("https://my.framework.com")
        expect(existing_framework.name).to eq("Books, stationery and education supplies")
        expect(existing_framework.ends_at).to eq(framework_data.ends_at)
        expect(existing_framework.description).to eq("Description of books")
      end
    end

    context "when the Framework does not already exist for the given provider_reference" do
      it "creates a new Framework with the given details" do
        expect { frameworks.import_from_faf(framework_data) }.to \
          change { Frameworks::Framework.where(provider_reference: "books").count }.from(0).to(1)

        new_framework = Frameworks::Framework.where(provider_reference: "books").first
        expect(new_framework.provider_url).to eq("https://my.framework.com")
        expect(new_framework.name).to eq("Books, stationery and education supplies")
        expect(new_framework.ends_at).to eq(framework_data.ends_at)
        expect(new_framework.description).to eq("Description of books")
      end
    end

    context "when the Provider with the given name does not already exist" do
      it "creates a new Provider linked to the Framework" do
        expect { frameworks.import_from_faf(framework_data) }.to \
          change { Frameworks::Provider.where(name: "Super Books LTD").count }.from(0).to(1)

        framework = Frameworks::Framework.where(provider_reference: "books").first
        expect(framework.provider.name).to eq("Super Books LTD")
      end
    end

    context "when the Provider with the given name already exists" do
      let!(:existing_provider) { create(:frameworks_provider, name: "Super Books LTD") }

      it "links the existing Provider to the Framework" do
        expect { frameworks.import_from_faf(framework_data) }.not_to \
          change { Frameworks::Provider.where(name: "Super Books LTD").count }.from(1)

        framework = Frameworks::Framework.where(provider_reference: "books").first
        expect(framework.provider).to eq(existing_provider)
      end
    end
  end
end
