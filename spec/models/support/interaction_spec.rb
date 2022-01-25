RSpec.describe Support::Interaction, type: :model do
  subject(:interaction) { create(:support_interaction) }

  it { is_expected.to belong_to :case }

  it "belongs to an agent" do
    expect(interaction.agent.first_name).to eq "first_name"
  end

  it "belongs to an case" do
    expect(interaction.case.request_text).to eq "This is an example request for support - please help!"
  end

  it "can be a note, email (inbound/outbound) or phone call" do
    expect(interaction).to define_enum_for(:event_type).with_values(%i[
      note phone_call email_from_school email_to_school support_request hub_notes hub_progress_notes hub_migration faf_support_request
    ])
  end

  describe "validations" do
    it "is invalid without a body" do
      interaction = build(:support_interaction, body: nil)
      expect(interaction).not_to be_valid
    end
  end
end
