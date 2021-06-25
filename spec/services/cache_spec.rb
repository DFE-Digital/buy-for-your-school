require "rails_helper"

RSpec.describe Cache do
  after do
    RedisCache.redis.flushdb
  end

  it "requires a key, enabled flag and ttl" do
    result = described_class.new(enabled: "true", ttl: 123)
    expect(result.enabled).to eql("true")
    expect(result.ttl).to be(123)
  end

  describe "#redis_cache" do
    it "returns an object that quacks like a redis instance (since MockRedis is used in Test)" do
      result = described_class.new(enabled: anything, ttl: anything)
        .redis_cache

      expect(result.respond_to?(:get)).to eq(true)
      expect(result.respond_to?(:set)).to eq(true)
      expect(result.respond_to?(:exists?)).to eq(true)
      expect(result.respond_to?(:expire)).to eq(true)
    end
  end

  describe "#hit?" do
    context "when enabled" do
      it "asks redis if that key exists" do
        cache = described_class.new(enabled: "true", ttl: anything)
        redis = cache.redis_cache

        expect(redis).to receive(:exists?).with("key-to-find")

        cache.hit?(key: "key-to-find")
      end
    end

    context "when disabled" do
      it "returns false" do
        cache = described_class.new(enabled: "false", ttl: anything)
        redis = cache.redis_cache

        expect(redis).not_to receive(:exists?).with("key-to-find")

        result = cache.hit?(key: "key-to-find")
        expect(result).to eq(false)
      end
    end
  end

  describe "#get" do
    it "asks redis to get that key" do
      cache = described_class.new(enabled: "false", ttl: anything)
      redis = cache.redis_cache

      expect(redis).to receive(:get).with("key-to-find")

      cache.get(key: "key-to-find")
    end
  end

  describe "#set" do
    context "when enabled" do
      it "asks redis to set that key with the ttl" do
        cache = described_class.new(enabled: "true", ttl: 123)
        redis = cache.redis_cache

        expect(redis).to receive(:set).with("key-to-set", "value-to-set")
        expect(redis).to receive(:expire).with("key-to-set", 123)

        cache.set(key: "key-to-set", value: "value-to-set")
      end
    end

    context "when disabled" do
      it "does not ask redis to set that key" do
        cache = described_class.new(enabled: "false", ttl: 123)
        redis = cache.redis_cache

        expect(redis).not_to receive(:set).with("key-to-set", "value-to-set")
        expect(redis).not_to receive(:expire).with("key-to-set", 123)

        cache.set(key: "key-to-set", value: "value-to-set")
      end
    end
  end

  describe ".delete" do
    context "when the key exists" do
      it "removes the key from redis and returns nil" do
        redis = RedisCache.redis
        allow(RedisCache).to receive(:redis).and_return(redis)

        target_key = "a-key:that-exists"
        redis.set(target_key, "a-dummy-value")

        expect(redis).to receive(:del).with(target_key).and_call_original

        described_class.delete(key: target_key)

        expect(redis.get(target_key)).to eq(nil)
      end
    end

    context "when the key doesn't already exist" do
      it "returns nil" do
        redis = RedisCache.redis
        allow(RedisCache).to receive(:redis).and_return(redis)

        target_key = "a-key:that-does-not-exist"

        expect(redis).to receive(:del).with(target_key).and_call_original

        described_class.delete(key: target_key)

        expect(redis.get(target_key)).to eq(nil)
      end
    end
  end

  describe "#extend_ttl_on_all_entries" do
    it "only updates redis keys associated to contentful entries" do
      cache = described_class.new(enabled: anything, ttl: anything)
      redis = cache.redis_cache

      redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:123", "value")
      expect(redis).to receive(:expire).with("#{Cache::ENTRY_CACHE_KEY_PREFIX}:123", (60 * 60 * 24) + -1)

      cache.extend_ttl_on_all_entries
    end

    context "when other redis keys exist" do
      it "only updates redis keys associated to contentful entries" do
        cache = described_class.new(enabled: anything, ttl: anything)
        redis = cache.redis_cache

        redis.set("another_key", "another_value")
        expect(redis).not_to receive(:expire).with("another_key")

        cache.extend_ttl_on_all_entries
      end
    end

    context "when the key already has a TTL" do
      it "sets a combined TTL with the existing and the extension" do
        cache = described_class.new(enabled: anything, ttl: anything)
        redis = cache.redis_cache

        redis.set("#{Cache::ENTRY_CACHE_KEY_PREFIX}:123", "value")
        redis.expire("#{Cache::ENTRY_CACHE_KEY_PREFIX}:123", 10)
        expect(redis).to receive(:expire).with("#{Cache::ENTRY_CACHE_KEY_PREFIX}:123", (60 * 60 * 24) + 10)

        cache.extend_ttl_on_all_entries
      end
    end
  end
end
