RSpec.describe "Case management tasks" do
  before do
    Rake.application.rake_require("tasks/case_management")
    Rake::Task.define_task(:environment)
  end

  describe "case_management:backfill_framework_requests_organisation_id" do
    let!(:school) { create(:support_organisation, urn: "01") }
    let!(:group) { create(:support_establishment_group, uid: "02") }
    let(:framework_request_school) { create(:framework_request, group: false, org_id: "01", organisation: nil) }
    let(:framework_request_group) { create(:framework_request, group: true, org_id: "02", organisation: nil) }

    it "backfills the organisation_id and organisation_type fields" do
      expect(framework_request_school.organisation).to be_nil
      expect(framework_request_group.organisation).to be_nil

      Rake::Task[self.class.description].invoke

      expect(framework_request_school.reload.organisation).to eq school
      expect(framework_request_group.reload.organisation).to eq group
    end
  end
end
