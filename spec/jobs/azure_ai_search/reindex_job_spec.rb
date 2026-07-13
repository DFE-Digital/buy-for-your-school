RSpec.describe AzureAiSearch::ReindexJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the default queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("default")
    end
  end

  describe "#perform" do
    let(:indexer) { instance_double(AzureAiSearch::SolutionIndexer, sync_all: { deleted: [], indexed: [] }) }

    before do
      allow(AzureAiSearch::SolutionIndexer).to receive(:new).and_return(indexer)
    end

    it "reindexes solutions in Azure AI Search" do
      described_class.perform_now

      expect(indexer).to have_received(:sync_all).once
    end
  end
end
