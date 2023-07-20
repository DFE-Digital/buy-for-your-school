RSpec.describe Support::RefreshEstablishmentGroupsJob, type: :job do
  include ActiveJob::TestHelper

  include_context "with establishment group data"

  before do
    ActiveJob::Base.queue_adapter = :test

    create(:support_establishment_group_type, code: 1, name: "Federation")

    travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)

    stub_request(:get, "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata20041124.csv")
    .to_return(body: File.open(establishment_group_data))
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the support queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("support")
    end

    it "creates and updates schools periodically" do
      expect(Support::EstablishmentGroup.count).to be_zero

      described_class.perform_later
      perform_enqueued_jobs

      expect(Support::EstablishmentGroup.count).to be 1
    end
  end
end
