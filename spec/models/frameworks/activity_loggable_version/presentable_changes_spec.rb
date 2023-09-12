require "rails_helper"

describe Frameworks::ActivityLoggableVersion::PresentableChanges do
  describe "#each" do
    context "with simple object changes" do
      it "returns each change with the values presented" do
        contact = create(:frameworks_provider_contact, name: "Contact 1")
        contact.update!(name: "Contact 2")

        presentable_changes = described_class.new(contact.versions.last)
        expect(presentable_changes.first.field).to eq("name")
        expect(presentable_changes.first.from).to eq("Contact 1")
        expect(presentable_changes.first.to).to eq("Contact 2")
      end

      context "when the presentable object has defined a custom way to present the field" do
        before do
          Frameworks::ProviderContact.class_eval do
            def display_field_version_name(name)
              "Funky #{name}"
            end
          end
        end

        it "uses the presentable version of the field that has been changed" do
          contact = create(:frameworks_provider_contact, name: "Contact 1")
          contact.update!(name: "Contact 2")

          presentable_changes = described_class.new(contact.versions.last)
          expect(presentable_changes.first.field).to eq("name")
          expect(presentable_changes.first.from).to eq("Funky Contact 1")
          expect(presentable_changes.first.to).to eq("Funky Contact 2")
        end
      end
    end

    context "with association changes" do
      it "returns the display name of the related object" do
        provider1 = create(:frameworks_provider, name: "Provider 1")
        provider2 = create(:frameworks_provider, name: "Provider 2")

        contact = create(:frameworks_provider_contact, provider: provider1)
        contact.update!(provider: provider2)

        presentable_changes = described_class.new(contact.versions.last)
        expect(presentable_changes.first.field).to eq("provider_id")
        expect(presentable_changes.first.from).to eq("Provider 1")
        expect(presentable_changes.first.to).to eq("Provider 2")
      end

      context "when the association itself has changed since the version stored" do
        it "returns the display name of the related object as it would have been at the time of change" do
          provider1 = create(:frameworks_provider, name: "Provider 1")
          provider2 = create(:frameworks_provider, name: "Provider 2")

          contact = create(:frameworks_provider_contact, provider: provider1)
          contact.update!(provider: provider2)
          provider2.update!(name: "Provider 2 new and improved")

          presentable_changes = described_class.new(contact.versions.last)
          expect(presentable_changes.first.field).to eq("provider_id")
          expect(presentable_changes.first.from).to eq("Provider 1")
          expect(presentable_changes.first.to).to eq("Provider 2")
        end
      end
    end
  end
end
