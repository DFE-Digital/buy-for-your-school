RSpec.describe Support::RefreshSchoolsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test

    group = create(:support_group, code: 4, name: "LA maintained school")
    create(:support_establishment_type, code: 1, name: "Community school", group: group)

    travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)

    # fixture contains 3 schools
    # the "voluntary aided school" is skipped
    # the "closed" school is skipped
    stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20041124.csv")
    .to_return(body: File.open("spec/fixtures/gias/example_schools_data.csv"))
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the default queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("support")
    end

    it "creates and updates schools periodically" do
      expect(Support::Organisation.count).to be_zero

      expect(Rollbar).to receive(:info).with("GIAS data has been refreshed")

      described_class.perform_later
      perform_enqueued_jobs

      expect(Support::Organisation.count).to be 1

      expect(Support::Organisation.first).to be_open
      expect(Support::Organisation.first).to be_mixed
      expect(Support::Organisation.first).to be_secondary
    end
  end
end
