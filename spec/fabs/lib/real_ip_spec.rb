require "rails_helper"

RSpec.describe RealIp do
  subject(:middleware) { described_class.new(dummy_app) }

  let(:dummy_app) { ->(_env) { [200, {}, %w[OK]] } }

  describe "#call" do
    it "sets HTTP_X_REAL_IP to the first IP in HTTP_X_FORWARDED_FOR" do
      env = { "HTTP_X_FORWARDED_FOR" => "1.2.3.4, 5.6.7.8" }
      middleware.call(env)
      expect(env["HTTP_X_REAL_IP"]).to eq "1.2.3.4"
    end

    it "does not set HTTP_X_REAL_IP when header is missing or blank" do
      [{}, { "HTTP_X_FORWARDED_FOR" => "" }].each do |e|
        middleware.call(e)
        expect(e).not_to have_key("HTTP_X_REAL_IP")
      end
    end
  end
end
