RSpec.describe Support::Agent, type: :model do
  subject(:agent) { create(:support_agent) }

  it "has a first name" do
    expect(agent.first_name).to eq("John")
  end

  it "has a last name" do
    expect(agent.last_name).to eq("Lennon")
  end

  it { is_expected.to have_many :cases }
end
