RSpec.describe Support::Interaction, type: :model do
  subject(:interaction) { create(:support_interaction, trait) }

  let(:trait) { :note }

  it { is_expected.to belong_to :case }

  it "belongs to an agent" do
    expect(interaction.agent.first_name).to eq "first_name"
  end

  it "belongs to an case" do
    expect(interaction.case.request_text).to eq "This is an example request for support - please help!"
  end

  it "can be a note, email (inbound/outbound), phone call, framework request, procurement details update, existing contract update, new contract update, savings update or status change" do
    expect(interaction).to define_enum_for(:event_type).with_values(%i[
      note
      phone_call
      email_from_school
      email_to_school
      support_request
      hub_notes
      hub_progress_notes
      hub_migration
      faf_support_request
      procurement_updated
      existing_contract_updated
      new_contract_updated
      savings_updated
      state_change
      email_merge
      create_case
      case_categorisation_changed
      case_source_changed
      case_assigned
      case_opened
      case_organisation_changed
      case_contact_changed
      case_level_changed
      case_procurement_stage_changed
      case_with_school_changed
      case_next_key_date_changed
      case_transferred
      evaluator_added
      evaluator_updated
      evaluator_removed
      evaluation_due_date_added
      evaluation_due_date_updated
      documents_uploaded
      documents_deleted
      all_documents_uploaded
      email_evaluators
      documents_downloaded
      completed_documents_uploaded
      completed_documents_deleted
      all_completed_documents_uploaded
      evaluation_completed
      contract_recipient_added
      contract_recipient_updated
      contract_recipient_removed
      handover_packs_uploaded
      handover_packs_deleted
      all_handover_packs_uploaded
      share_handover_packs
      handover_packs_downloaded
      documents_uploaded_in_complete
      completed_documents_uploaded_in_complete
      handover_packs_uploaded_in_complete
      evaluation_in_completed
    ])
  end

  describe "validations" do
    it "is invalid without a body" do
      interaction = build(:support_interaction, body: nil)
      expect(interaction).not_to be_valid
    end
  end

  describe ".templated_messages" do
    before do
      create(:support_interaction, :email_from_school, additional_data: { email_template: "template" })
      create(:support_interaction, :email_to_school, additional_data: { email_template: "template" })
    end

    it "returns message interactions that have an email template" do
      expect(described_class.templated_messages.size).to eq 2
      expect(described_class.templated_messages.map(&:additional_data)).to all(have_key("email_template"))
    end
  end

  describe ".logged_contacts" do
    before do
      create(:support_interaction, :email_from_school, additional_data: {})
      create(:support_interaction, :email_to_school, additional_data: {})
      create(:support_interaction, :phone_call, additional_data: {})
    end

    it "returns email and phone interactions with no additional data" do
      expect(described_class.logged_contacts.size).to eq 3
      expect(described_class.logged_contacts.map(&:additional_data)).to all(eq({}))
    end
  end

  describe "#contact?" do
    context "when the event type is email_from_school" do
      let(:trait) { :email_from_school }

      it "returns true" do
        expect(interaction.contact?).to eq(true)
      end
    end

    context "when the event type is email_to_school" do
      let(:trait) { :email_to_school }

      it "returns true" do
        expect(interaction.contact?).to eq(true)
      end
    end

    context "when the event type is phone_call" do
      let(:trait) { :phone_call }

      it "returns true" do
        expect(interaction.contact?).to eq(true)
      end
    end
  end
end
