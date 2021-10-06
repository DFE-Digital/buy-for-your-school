RSpec.describe Support::Agent, type: :model do
  it { is_expected.to have_many :cases }

  describe "attributes" do
    subject(:agent) do
      create(:support_agent,
             dsi_uid: "unique id",
             email: "test@test",
             first_name: "John",
             last_name: "Lennon")
    end

    it { is_expected.to be_persisted }

    it "requires a DfE Sign In unique id" do
      expect { create(:support_agent, dsi_uid: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires an email" do
      expect { create(:support_agent, email: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires a first_name and last_name" do
      expect { create(:support_agent, first_name: nil) }.to raise_error(ActiveRecord::NotNullViolation)
      expect { create(:support_agent, last_name: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
