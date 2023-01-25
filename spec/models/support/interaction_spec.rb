RSpec.describe Support::Interaction, type: :model do
  subject(:interaction) { create(:support_interaction) }

  it { is_expected.to belong_to :case }

  it "belongs to an agent" do
    expect(interaction.agent.first_name).to eq "first_name"
  end

  it "belongs to an case" do
    expect(interaction.case.request_text).to eq "This is an example request for support - please help!"
  end

  it "can be a note, email (inbound/outbound), phone call, framework request, procurement details update, existing contract update, new contract update, savings update or status change" do
    expect(interaction).to define_enum_for(:event_type).with_values(%i[
      note phone_call email_from_school email_to_school support_request hub_notes hub_progress_notes hub_migration faf_support_request procurement_updated existing_contract_updated new_contract_updated savings_updated state_change email_merge create_case case_categorisation_changed case_source_changed
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
end
