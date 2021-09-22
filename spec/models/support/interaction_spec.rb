RSpec.describe Support::Interaction, type: :model do
  subject(:interaction) { create(:support_interaction) }

  it "belongs to an agent" do
    expect(interaction.agent).not_to be_nil
    expect(interaction.agent.first_name).to eq "John"
  end

  it "belongs to an case" do
    expect(interaction.case).not_to be_nil
    expect(interaction.case.request_text).to eq "This is an example request for support - please help!"
  end

  it { is_expected.to define_enum_for(:event_type).with_values(%i[note phone_call email_from_school email_to_school]) }

  describe "validations" do
    it "is not valid if there is no body" do
      interaction = build(:support_interaction, body: nil)
      expect(interaction).not_to be_valid
    end
  end
end
