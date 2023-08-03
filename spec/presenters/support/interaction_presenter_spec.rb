RSpec.describe Support::InteractionPresenter do
  subject(:presenter) { described_class.new(interaction) }

  let(:organisation) { create(:support_organisation, :fixed_name, name: "Example Organisation") }
  let(:category) { create(:support_category, :fixed_title, title: "Example Category") }
  let(:additional_data) { nil }
  let(:interaction) { build(:support_interaction, body: "\n foo \n", additional_data:) }

  let(:event_types) do
    {
      note: 0,
      phone_call: 1,
      email_from_school: 2,
      email_to_school: 3,
      support_request: 4,
      hub_notes: 5,
      progress_notes: 6,
      hub_migration: 7,
      faf_support_request: 8,
      procurement_updated: 9,
      existing_contract_updated: 10,
      new_contract_updated: 11,
      savings_updated: 12,
    }
  end

  describe "#body" do
    it "strips new lines" do
      expect(presenter.body).to eq("foo")
    end
  end

  describe "#contact_options" do
    it "returns a formatted hash for the log contact form" do
      expect(presenter.contact_options).to match_array([
        have_attributes(id: "phone_call", label: "Phone call"),
        have_attributes(id: "email_from_school", label: "Email from school"),
        have_attributes(id: "email_to_school", label: "Email to school"),
        have_attributes(id: "case_organisation_changed", label: "Case organisation changed"),
        have_attributes(id: "case_contact_changed", label: "Case contact changed"),
        have_attributes(id: "case_level_changed", label: "Case level changed"),
        have_attributes(id: "case_with_school_changed", label: "Case with school changed"),
      ])
    end
  end

  context "with additonal data" do
    let(:additional_data) do
      {
        organisation_name: organisation.name,
        category_id: category.id,
        support_request_id: "000001",
      }
    end

    describe "#additional_data" do
      it "returns a formatted hash with the organsiation name" do
        expect(presenter.additional_data).to include("organisation_name" => "Example Organisation")
      end

      it "returns a formatted hash with the category name" do
        expect(presenter.additional_data).to include("category_id" => "Example Category")
      end

      it "returns a formatted hash removing support id" do
        expect(presenter.additional_data).not_to include("support_request_id" => "000001")
      end
    end
  end
end
