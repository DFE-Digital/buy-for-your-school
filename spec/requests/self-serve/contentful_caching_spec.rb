require "rails_helper"

RSpec.describe "Contentful Caching", type: :request do
  before { user_is_signed_in }

  context "when caching is enabled" do
    around do |example|
      ClimateControl.modify(CONTENTFUL_ENTRY_CACHING: "true") do
        example.run
      end
    end

    after { RedisCache.redis.flushdb }

    # TODO: revise this spec and understand the todos below
    it "checks the Redis cache instead of making an external request" do
      # TODO: In reality we do not cache categories, but should
      raw_category_response = File.read(Rails.root.join("spec/fixtures/contentful/001-categories/radio-question.json"))
      RedisCache.redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:contentful-category-entry", JSON.dump(raw_category_response))

      # TODO: In reality we do not cache sections, but should
      raw_section_response = File.read(Rails.root.join("spec/fixtures/contentful/002-sections/radio-section.json"))
      RedisCache.redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-section", JSON.dump(raw_section_response))

      raw_step_response = File.read(Rails.root.join("spec/fixtures/contentful/003-tasks/radio-task.json"))
      RedisCache.redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-task", JSON.dump(raw_step_response))

      raw_step_response = File.read(Rails.root.join("spec/fixtures/contentful/004-steps/radio-question.json"))
      RedisCache.redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question", JSON.dump(raw_step_response))

      expect_any_instance_of(Contentful::Client).not_to receive(:entry)

      contentful_category = stub_contentful_category(
        fixture_filename: "radio-question.json",
      )
      category = persist_category(contentful_category)

      post journeys_path, params: { new_journey_form: { category: category.slug, name: "test" } }

      expect(response).to have_http_status(:found)

      RedisCache.redis.del("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question")
    end

    it "stores the external contentful response in the cache" do
      contentful_category = stub_contentful_category(
        fixture_filename: "radio-question.json",
      )
      category = persist_category(contentful_category)

      post journeys_path, params: { new_journey_form: { category: category.slug, name: "test" } }

      expect(RedisCache.redis.get("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question"))
        .to eq("\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"jspwts36h1os\\\"}},\\\"id\\\":\\\"radio-question\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-09-07T10:56:40.585Z\\\",\\\"updatedAt\\\":\\\"2020-09-14T22:16:54.633Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"master\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":7,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"question\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/which-service\\\",\\\"title\\\":\\\"Which service do you need?\\\",\\\"helpText\\\":\\\"Tell us which service you need.\\\",\\\"type\\\":\\\"radios\\\",\\\"extendedOptions\\\":[{\\\"value\\\":\\\"Catering\\\"},{\\\"value\\\":\\\"Cleaning\\\"}],\\\"alwaysShowTheUser\\\":true}}\"")

      RedisCache.redis.del("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question")
    end

    it "sets a TTL to 72 hours by default" do
      contentful_category = stub_contentful_category(
        fixture_filename: "radio-question.json",
      )
      category = persist_category(contentful_category)

      freeze_time do
        post journeys_path, params: { new_journey_form: { category: category.slug, name: "test" } }

        expect(RedisCache.redis.ttl("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question"))
          .to eq(60 * 60 * 72)
      end

      RedisCache.redis.del("#{Cache::ENTRY_CACHE_KEY_PREFIX}:radio-question")
    end
  end

  context "when caching has been disabled in ENV" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_ENTRY_CACHING: "false",
      ) do
        example.run
      end
    end

    it "does not interact with the redis cache" do
      contentful_category = stub_contentful_category(
        fixture_filename: "radio-question.json",
      )
      category = persist_category(contentful_category)

      expect(RedisCache).not_to receive(:redis)

      post journeys_path, params: { new_journey_form: { category: category.slug, name: "test" } }
    end
  end
end
