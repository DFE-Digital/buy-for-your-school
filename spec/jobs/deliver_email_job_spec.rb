RSpec.describe DeliverEmailJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(Email::Draft).to receive(:find).and_return(draft)
    described_class.perform_later(email_id, send_type)
    perform_enqueued_jobs
  end

  let(:draft) { double(:draft, deliver_as_new_message: nil, delivery_as_reply: nil) }
  let(:email_id) { 42 }
  let(:send_type) { :as_new_message }

  describe ".perform_later" do
    it "enqueues a job asynchronously on the emailing queue" do
      expect { described_class.perform_later }.to have_enqueued_job.on_queue("emailing")
    end

    it "finds the correct email" do
      expect(Email::Draft).to have_received(:find).with(email_id)
    end

    context "when called with :as_new_message" do
      it "delivers the draft as a new message" do
        expect(draft).to have_received(:deliver_as_new_message)
      end
    end

    context "when called with :as_reply" do
      let(:send_type) { :as_reply }

      it "delivers the draft as a reply" do
        expect(draft).to have_received(:delivery_as_reply)
      end
    end
  end
end
