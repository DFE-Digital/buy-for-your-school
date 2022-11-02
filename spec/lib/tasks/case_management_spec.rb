RSpec.describe "Case management tasks" do
  before do
    Rake.application.rake_require("tasks/case_management")
    Rake::Task.define_task(:environment)
  end

  describe "case_management:send_all_cases_survey" do
    it "passes given case references to the survey job" do
      expect(Support::SendAllCasesSurveyJob).to receive(:perform_later).with("000001")
      expect(Support::SendAllCasesSurveyJob).to receive(:perform_later).with("000002")
      expect(Support::SendAllCasesSurveyJob).to receive(:perform_later).with("000003")

      Rake::Task["case_management:send_all_cases_survey"].invoke(Rails.root.join("spec/fixtures/lib/tasks/case_ref.csv"))
    end
  end
end
