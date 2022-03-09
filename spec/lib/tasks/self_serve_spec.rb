RSpec.describe "Self-serve tasks" do
  before do
    Rake.application.rake_require("tasks/self_serve")
    Rake::Task.define_task(:environment)
  end

  describe "self_serve:backfill_journey_names" do
    let(:user) { create(:user) }
    let(:catering_journey_1) { create(:journey, category: create(:category, :catering), name: nil, user: user) }
    let(:catering_journey_2) { create(:journey, category: create(:category, :catering), name: nil, user: user) }
    let(:mfd_journey_1) { create(:journey, category: create(:category, :mfd), name: nil, user: user) }
    let(:mfd_journey_2) { create(:journey, category: create(:category, :mfd), name: nil, user: user) }

    it "gives names to journeys that do not have them" do
      expect(catering_journey_1.name).to be_nil
      expect(catering_journey_2.name).to be_nil
      expect(mfd_journey_1.name).to be_nil
      expect(mfd_journey_2.name).to be_nil

      Rake::Task["self_serve:backfill_journey_names"].invoke

      expect(catering_journey_1.reload.name).to eq "Catering specification 01"
      expect(catering_journey_2.reload.name).to eq "Catering specification 02"
      expect(mfd_journey_1.reload.name).to eq "Multi-functional devices specification 01"
      expect(mfd_journey_2.reload.name).to eq "Multi-functional devices specification 02"
    end
  end
end
