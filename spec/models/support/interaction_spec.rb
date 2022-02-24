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
      note phone_call email_from_school email_to_school support_request hub_notes hub_progress_notes hub_migration faf_support_request procurement_updated existing_contract_updated new_contract_updated savings_updated state_change
    ])
  end

  describe "validations" do
    it "is invalid without a body" do
      interaction = build(:support_interaction, body: nil)
      expect(interaction).not_to be_valid
    end
  end
end
