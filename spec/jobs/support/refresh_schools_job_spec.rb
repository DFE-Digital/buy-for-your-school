RSpec.describe Support::RefreshSchoolsJob, type: :job do
  include ActiveJob::TestHelper

  include_context "with gias data"

  before do
    ActiveJob::Base.queue_adapter = :test

    group_type = create(:support_group_type, code: 4, name: "LA maintained school")
    create(:support_establishment_type, code: 1, name: "Community school", group_type:)

    travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)

    stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20041124.csv")
    .to_return(body: File.open(gias_data))
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the support queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("support")
    end

    it "creates and updates schools periodically" do
      expect(Support::Organisation.count).to be_zero

      described_class.perform_later
      perform_enqueued_jobs

      expect(Support::Organisation.count).to be 1

      expect(Support::Organisation.first).to be_opened
      expect(Support::Organisation.first).to be_mixed
      expect(Support::Organisation.first).to be_secondary
    end
  end
end
