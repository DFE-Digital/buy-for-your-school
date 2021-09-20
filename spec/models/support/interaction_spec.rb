RSpec.describe Support::Interaction, type: :model do
  subject(:interaction) { create(:support_interaction) }

  it "belongs to an agent" do
    expect(interaction.agent).not_to be_nil
    expect(interaction.agent.first_name).to eq "John"
  end



end
