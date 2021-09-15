RSpec.describe Support::Agent, type: :model do
  subject(:agent) { create(:support_agent) }

  it "has a first name" do
    expect(agent.first_name).to eq("John")
  end

  it "has a last name" do
    expect(agent.last_name).to eq("Lennon")
  end

  context "when cases are assigned to it" do
    let(:support_case) { create(:support_case) }

    before do
      agent.cases << support_case
      agent.save!
    end

    it "has many cases" do
      expect(agent.cases).to include(support_case)
    end
  end
end
