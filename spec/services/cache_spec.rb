require "rails_helper"

RSpec.describe Cache do
  it "requires a key, enabled flag and ttl" do
    result = described_class.new(enabled: "true", ttl: 123)
    expect(result.enabled).to eql("true")
    expect(result.ttl).to eql(123)
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
end
