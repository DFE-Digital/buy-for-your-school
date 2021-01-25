require "rails_helper"

RSpec.describe WarmEntryCacheJob, type: :job do
  include ActiveJob::TestHelper

  before(:each) { ActiveJob::Base.queue_adapter = :test }
  after(:each) { RedisCache.redis.flushdb }

  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry",
      CONTENTFUL_ENTRY_CACHING: "true"
    ) do
      example.run
    end
  end

  describe ".perform_later" do
    it "enqueues a job asynchronously on the caching queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job.on_queue("caching")
    end

    it "asks GetAllContentfulEntries for the Contentful entries" do
      stub_contentful_category(
        fixture_filename: "journey-with-multiple-entries.json"
      )

      described_class.perform_later
      perform_enqueued_jobs

      expect(RedisCache.redis.get("contentful:entry:contentful-radio-question"))
        .to eql(
          "\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"jspwts36h1os\\\"}},\\\"id\\\":\\\"contentful-radio-question\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-09-07T10:56:40.585Z\\\",\\\"updatedAt\\\":\\\"2020-09-14T22:16:54.633Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"master\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":7,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"question\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/which-service\\\",\\\"title\\\":\\\"Which service do you need?\\\",\\\"helpText\\\":\\\"Tell us which service you need.\\\",\\\"type\\\":\\\"radios\\\",\\\"extendedOptions\\\":[{\\\"value\\\":\\\"Catering\\\"},{\\\"value\\\":\\\"Cleaning\\\"}]}}\""
        )
      expect(RedisCache.redis.get("contentful:entry:short-text-question"))
        .not_to be_nil

      expect(RedisCache.redis.get("contentful:entry:long-text-question"))
        .not_to be_nil
    end

    context "when the journey order cannot be built" do
      it "does not add new items to the cache" do
        allow_any_instance_of(GetEntriesInCategory)
          .to receive(:call)
          .and_raise(GetEntriesInCategory::RepeatEntryDetected)

        described_class.perform_later
        perform_enqueued_jobs

        expect(RedisCache.redis).not_to receive(:set).with("contentful:entry:contentful-starting-step", anything)
      end

      it "extends the TTL on all existing items by 24 hours" do
        RedisCache.redis.set("contentful:entry:contentful-starting-step", "\"{\\}\"")

        allow_any_instance_of(GetEntriesInCategory)
          .to receive(:call)
          .and_raise(GetEntriesInCategory::RepeatEntryDetected)

        freeze_time do
          ttl_extension = 60 * 60 * 24
          existing_ttl = -1

          expect(RedisCache.redis)
            .to receive(:expire)
            .with("contentful:entry:contentful-starting-step", ttl_extension + existing_ttl)

          described_class.perform_later
          perform_enqueued_jobs
        end
      end
    end
  end
end
