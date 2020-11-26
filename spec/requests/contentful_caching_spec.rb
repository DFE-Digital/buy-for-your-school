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
    plan = create(:plan, next_entry_id: "1UjQurSOi5MWkcRuGxdXZS")

    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")

    RedisCache.redis.set("contentful:entry:1UjQurSOi5MWkcRuGxdXZS", raw_response)

    expect_any_instance_of(Contentful::Client).not_to receive(:entry)

    get new_plan_question_path(plan)

    expect(response).to have_http_status(:success)

    RedisCache.redis.del("contentful:entry:1UjQurSOi5MWkcRuGxdXZS")
  end

  it "stores the external contentful response in the cache" do
    plan = create(:plan, next_entry_id: "1UjQurSOi5MWkcRuGxdXZS")
    raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")
    stub_get_contentful_entry(
      entry_id: "1UjQurSOi5MWkcRuGxdXZS",
      fixture_filename: "radio-question-example.json"
    )

    get new_plan_question_path(plan)

    expect(RedisCache.redis.get("contentful:entry:1UjQurSOi5MWkcRuGxdXZS"))
      .to eq(raw_response)

    RedisCache.redis.del("contentful:entry:1UjQurSOi5MWkcRuGxdXZS")
  end

  it "sets a TTL to 48 hours by default" do
    plan = create(:plan, next_entry_id: "1UjQurSOi5MWkcRuGxdXZS")
    stub_get_contentful_entry(
      entry_id: "1UjQurSOi5MWkcRuGxdXZS",
      fixture_filename: "radio-question-example.json"
    )

    freeze_time do
      get new_plan_question_path(plan)

      expect(RedisCache.redis.ttl("contentful:entry:1UjQurSOi5MWkcRuGxdXZS"))
        .to eq(172_800)
    end

    RedisCache.redis.del("contentful:entry:1UjQurSOi5MWkcRuGxdXZS")
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
      plan = create(:plan, next_entry_id: "1UjQurSOi5MWkcRuGxdXZS")
      stub_get_contentful_entry(
        entry_id: "1UjQurSOi5MWkcRuGxdXZS",
        fixture_filename: "radio-question-example.json"
      )

      expect(RedisCache).not_to receive(:redis)

      get new_plan_question_path(plan)
    end
  end
end
