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

      expect(RedisCache.redis.get("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question"))
        .to eql(
          "\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"jspwts36h1os\\\"}},\\\"id\\\":\\\"radio-question\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-09-07T10:56:40.585Z\\\",\\\"updatedAt\\\":\\\"2020-09-14T22:16:54.633Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"master\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":7,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"question\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/which-service\\\",\\\"title\\\":\\\"Which service do you need?\\\",\\\"helpText\\\":\\\"Tell us which service you need.\\\",\\\"type\\\":\\\"radios\\\",\\\"extendedOptions\\\":[{\\\"value\\\":\\\"Catering\\\"},{\\\"value\\\":\\\"Cleaning\\\"}],\\\"alwaysShowTheUser\\\":true}}\""
        )
      expect(RedisCache.redis.get("#{Cache::ENTRY_CACHE_KEY_PREFIX}:short-text-question"))
        .not_to be_nil

      expect(RedisCache.redis.get("#{Cache::ENTRY_CACHE_KEY_PREFIX}:long-text-question"))
        .not_to be_nil
    end

    context "when the journey order cannot be built due to an entry being repeated" do
      it "does not add new items to the cache" do
        stub_contentful_category(
          fixture_filename: "journey-with-repeat-entries.json"
        )

        allow_any_instance_of(GetStepsFromTask)
          .to receive(:call)
          .and_raise(GetStepsFromTask::RepeatEntryDetected)

        described_class.perform_later
        perform_enqueued_jobs

        expect(RedisCache.redis).not_to receive(:set).with("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question", anything)
      end

      it "raises an error to the team via Rollbar to indicate an issue" do
        stub_contentful_category(
          fixture_filename: "journey-with-repeat-entries.json"
        )

        allow_any_instance_of(GetStepsFromTask)
          .to receive(:call)
          .and_raise(GetStepsFromTask::RepeatEntryDetected)

        expect(Rollbar).to receive(:error)
          .with("Cache warming task failed. The old cached data was extended by 24 hours.")
          .and_call_original

        described_class.perform_later
        perform_enqueued_jobs
      end

      it "extends the TTL on all existing items by 72 hours" do
        default_caching_ttl = 60 * 60 * 72
        old_cache_value = "\"{\\}\""

        RedisCache.redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question", old_cache_value)
        RedisCache.redis.expire("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question", default_caching_ttl)

        stub_contentful_category(
          fixture_filename: "journey-with-repeat-entries.json"
        )

        allow_any_instance_of(GetStepsFromTask)
          .to receive(:call)
          .and_raise(GetStepsFromTask::RepeatEntryDetected)

        freeze_time do
          described_class.perform_later
          perform_enqueued_jobs

          expect(RedisCache.redis.ttl("#{Cache::ENTRY_CACHE_KEY_PREFIX}:journey-with-repeat-entries-section")).to eql(default_caching_ttl)
          expect(RedisCache.redis.ttl("#{Cache::ENTRY_CACHE_KEY_PREFIX}:repeat-entries-task")).to eql(default_caching_ttl)
          expect(RedisCache.redis.ttl("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question")).to eql(default_caching_ttl)

          # The content of the cache should not be changed to the contents of the fixture.
          expect(RedisCache.redis.get("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question")).to eql(old_cache_value)
        end
      end
    end
  end
end
