require "rails_helper"

RSpec.describe RealIp do
  subject(:middleware) { described_class.new(app) }

  let(:app) { ->(env) { [200, env, ["OK"]] } }
  let(:request) { instance_double(ActionDispatch::Request, remote_ip:) }
  let(:remote_ip) { "203.0.113.10" }

  before do
    allow(ActionDispatch::Request).to receive(:new).and_return(request)
  end

  it "sets HTTP_X_REAL_IP from ActionDispatch::Request#remote_ip" do
    _status, env, = middleware.call({})

    expect(env["HTTP_X_REAL_IP"]).to eq("203.0.113.10")
  end

  context "when remote_ip is nil" do
    let(:remote_ip) { nil }

    it "does not set HTTP_X_REAL_IP" do
      _status, env, = middleware.call({})

      expect(env).not_to have_key("HTTP_X_REAL_IP")
    end
  end
end
