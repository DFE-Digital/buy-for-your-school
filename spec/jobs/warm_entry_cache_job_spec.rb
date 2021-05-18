require "rails_helper"

RSpec.describe WarmEntryCacheJob, type: :job do
  include ActiveJob::TestHelper

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end
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
      stub_contentful_category(fixture_filename: "journey-with-multiple-entries.json")

      described_class.perform_later
      perform_enqueued_jobs

      expect(RedisCache.redis.get("contentful:entry:radio-question"))
        .to eql(
          "\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"jspwts36h1os\\\"}},\\\"id\\\":\\\"radio-question\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-09-07T10:56:40.585Z\\\",\\\"updatedAt\\\":\\\"2020-09-14T22:16:54.633Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"master\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":7,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"question\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/which-service\\\",\\\"title\\\":\\\"Which service do you need?\\\",\\\"helpText\\\":\\\"Tell us which service you need.\\\",\\\"type\\\":\\\"radios\\\",\\\"extendedOptions\\\":[{\\\"value\\\":\\\"Catering\\\"},{\\\"value\\\":\\\"Cleaning\\\"}],\\\"alwaysShowTheUser\\\":true}}\""
        )
      expect(RedisCache.redis.get("contentful:entry:short-text-question"))
        .not_to be_nil

      expect(RedisCache.redis.get("contentful:entry:long-text-question"))
        .not_to be_nil
    end

    context "when the journey order cannot be built due to an entry being repeated" do
      it "does not add new items to the cache" do
        stub_contentful_category(
          fixture_filename: "journey-with-repeat-entries.json"
        )

        allow_any_instance_of(GetStepsFromSection)
          .to receive(:call)
          .and_raise(GetStepsFromSection::RepeatEntryDetected)

        described_class.perform_later
        perform_enqueued_jobs

        expect(RedisCache.redis).not_to receive(:set).with("contentful:entry:radio-question", anything)
      end

      it "extends the TTL on all existing items by 24 hours" do
        RedisCache.redis.set("contentful:entry:radio-question", "\"{\\}\"")

        stub_contentful_category(
          fixture_filename: "journey-with-repeat-entries.json"
        )

        allow_any_instance_of(GetStepsFromSection)
          .to receive(:call)
          .and_raise(GetStepsFromSection::RepeatEntryDetected)

        freeze_time do
          ttl_default = 60 * 60 * 72
          ttl_extension = 60 * 60 * 24
          existing_ttl = -1

          # When section is first stored in the cache it is set with a default TTL
          expect(RedisCache.redis)
            .to receive(:expire)
            .with("contentful:entry:journey-with-repeat-entries-section", ttl_default)

          # All cached items are extended by 24 hours
          expect(RedisCache.redis)
          .to receive(:expire)
          .with("contentful:entry:journey-with-repeat-entries-section", ttl_extension + existing_ttl)

          expect(RedisCache.redis)
            .to receive(:expire)
            .with("contentful:entry:radio-question", ttl_extension + existing_ttl)

          described_class.perform_later
          perform_enqueued_jobs
        end
      end
    end
  end
end
