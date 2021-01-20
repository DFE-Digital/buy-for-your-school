require "rails_helper"

RSpec.describe "Contentful Caching", type: :request do
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_ENTRY_CACHING: "true"
    ) do
      example.run
    end
  end

  it "checks the Redis cache instead of making an external request" do
    journey = create(:journey, next_entry_id: "contentful-radio-question")

    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")
    RedisCache.redis.set("contentful:entry:contentful-radio-question", JSON.dump(raw_response))

    expect_any_instance_of(Contentful::Client).not_to receive(:entry)

    get new_journey_step_path(journey)

    expect(response).to have_http_status(:found)

    RedisCache.redis.del("contentful:entry:contentful-radio-question")
  end

  it "stores the external contentful response in the cache" do
    journey = create(:journey, next_entry_id: "contentful-radio-question")
    stub_get_contentful_entry(
      entry_id: "contentful-radio-question",
      fixture_filename: "radio-question-example.json"
    )

    get new_journey_step_path(journey)

    expect(RedisCache.redis.get("contentful:entry:contentful-radio-question"))
      .to eq("\"{\\\"sys\\\":{\\\"space\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Space\\\",\\\"id\\\":\\\"jspwts36h1os\\\"}},\\\"id\\\":\\\"contentful-radio-question\\\",\\\"type\\\":\\\"Entry\\\",\\\"createdAt\\\":\\\"2020-09-07T10:56:40.585Z\\\",\\\"updatedAt\\\":\\\"2020-09-14T22:16:54.633Z\\\",\\\"environment\\\":{\\\"sys\\\":{\\\"id\\\":\\\"master\\\",\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"Environment\\\"}},\\\"revision\\\":7,\\\"contentType\\\":{\\\"sys\\\":{\\\"type\\\":\\\"Link\\\",\\\"linkType\\\":\\\"ContentType\\\",\\\"id\\\":\\\"question\\\"}},\\\"locale\\\":\\\"en-US\\\"},\\\"fields\\\":{\\\"slug\\\":\\\"/which-service\\\",\\\"title\\\":\\\"Which service do you need?\\\",\\\"helpText\\\":\\\"Tell us which service you need.\\\",\\\"type\\\":\\\"radios\\\",\\\"extendedOptions\\\":[{\\\"value\\\":\\\"Catering\\\"},{\\\"value\\\":\\\"Cleaning\\\"}]}}\"")

    RedisCache.redis.del("contentful:entry:contentful-radio-question")
  end

  it "sets a TTL to 72 hours by default" do
    journey = create(:journey, next_entry_id: "contentful-radio-question")
    stub_get_contentful_entry(
      entry_id: "contentful-radio-question",
      fixture_filename: "radio-question-example.json"
    )

    freeze_time do
      get new_journey_step_path(journey)

      expect(RedisCache.redis.ttl("contentful:entry:contentful-radio-question"))
        .to eq(60 * 60 * 72)
    end

    RedisCache.redis.del("contentful:entry:contentful-radio-question")
  end

  context "when caching has been disabled in ENV" do
    around do |example|
      ClimateControl.modify(
        CONTENTFUL_ENTRY_CACHING: "false"
      ) do
        example.run
      end
    end

    it "does not interact with the redis cache" do
      journey = create(:journey, next_entry_id: "contentful-radio-question")
      stub_get_contentful_entry(
        entry_id: "contentful-radio-question",
        fixture_filename: "radio-question-example.json"
      )

      expect(RedisCache).not_to receive(:redis)

      get new_journey_step_path(journey)
    end
  end
end
