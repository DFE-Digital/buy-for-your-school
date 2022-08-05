RSpec.describe "Self-serve tasks" do
  before do
    Rake.application.rake_require("tasks/self_serve")
    Rake::Task.define_task(:environment)
  end

  describe "self_serve:backfill_journey_names" do
    let(:user) { create(:user) }
    let(:catering_journey_1) { create(:journey, category: create(:category, :catering), name: nil, user:) }
    let(:catering_journey_2) { create(:journey, category: create(:category, :catering), name: nil, user:) }
    let(:mfd_journey_1) { create(:journey, category: create(:category, :mfd), name: nil, user:) }
    let(:mfd_journey_2) { create(:journey, category: create(:category, :mfd), name: nil, user:) }

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

  describe "self_serve:backfill_contentful_text" do
    let(:activity_log_1) { create(:activity_log_item, category: create(:category, :catering), user_id: create(:user), journey_id: create(:journey), section: create(:section), step: create(:step, :additional_steps), task: create(:task)) }
    # testing the rake task works when there is no section as an example
    let(:activity_log_2) { create(:activity_log_item, category: create(:category, :mfd), user_id: create(:user), journey_id: create(:journey), section: nil, step: create(:step, :additional_steps), contentful_section_id: nil) }

    it "gives contentful text to activity logs that do not have them" do
      expect(activity_log_1.contentful_category).to be_nil
      expect(activity_log_1.contentful_section).to be_nil
      expect(activity_log_1.contentful_task).to be_nil
      expect(activity_log_1.contentful_step).to be_nil

      expect(activity_log_2.contentful_category).to be_nil
      expect(activity_log_2.contentful_section).to be_nil

      Rake::Task["self_serve:backfill_contentful_text"].invoke

      expect(activity_log_1.reload.contentful_category).to eq "Catering"
      expect(activity_log_1.reload.contentful_section).to eq "Section title"
      expect(activity_log_1.reload.contentful_task).to eq "Task title"
      expect(activity_log_1.reload.contentful_step).to eq "has additional steps"

      expect(activity_log_2.reload.contentful_category).to eq "Multi-functional devices"
      expect(activity_log_2.reload.contentful_section).to be_nil
    end
  end
end
