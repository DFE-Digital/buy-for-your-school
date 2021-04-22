require "rails_helper"

RSpec.describe UserSession, type: :model do
  include Rails.application.routes.url_helpers
  let(:session) { double(ActionDispatch::Request::Session) }

  describe "#persist_successful_dfe_sign_in_claim!" do
    it "stores the DfE Sign-in UID in the session" do
      omniauth_hash = {
        "uid" => "123",
        "credentials" => {
          "id_token" => "456"
        }
      }

      user_session = described_class.new(session: session)

      expect(session).to receive(:[]=).with(:dfe_sign_in_uid, "123")
      expect(session).to receive(:[]=).with(:dfe_sign_in_sign_out_token, "456")

      user_session.persist_successful_dfe_sign_in_claim!(omniauth_hash: omniauth_hash)
    end
  end

  describe "#repudiate!" do
    it "removes the DfE sign in claim from the session" do
      user_session = described_class.new(session: session)

      expect(session).to receive(:delete).with(:dfe_sign_in_uid)
      expect(session).to receive(:delete).with(:dfe_sign_in_sign_out_token)

      user_session.repudiate!
    end
  end

  describe "#should_be_signed_out_of_dsi?" do
    it "returns true when there is a sign out token" do
      session_with_sign_out_token = double(ActionDispatch::Request::Session)
      allow(session_with_sign_out_token)
        .to receive(:key?)
        .with(:dfe_sign_in_sign_out_token)
        .and_return(true)

      allow(session_with_sign_out_token)
        .to receive(:[])
        .with(:dfe_sign_in_sign_out_token)
        .and_return("a-long-token")

      result = described_class.new(session: session_with_sign_out_token)
        .should_be_signed_out_of_dsi?

      expect(result).to eq(true)
    end

    it "returns false when the sign out token value is blank" do
      session_with_sign_out_token = double(ActionDispatch::Request::Session)
      allow(session_with_sign_out_token)
        .to receive(:key?)
        .with(:dfe_sign_in_sign_out_token)
        .and_return(true)

      allow(session_with_sign_out_token)
        .to receive(:[])
        .with(:dfe_sign_in_sign_out_token)
        .and_return("")

      result = described_class.new(session: session_with_sign_out_token)
        .should_be_signed_out_of_dsi?

      expect(result).to eq(false)
    end

    it "returns false when there is no sign out token" do
      session_without_sign_in_token = double(ActionDispatch::Request::Session)
      allow(session_without_sign_in_token)
        .to receive(:key?)
        .with(:dfe_sign_in_sign_out_token)
        .and_return(false)

      result = described_class.new(session: session_without_sign_in_token)
        .should_be_signed_out_of_dsi?

      expect(result).to eq(false)
    end
  end

  describe "#sign_out_url" do
    around do |example|
      ClimateControl.modify(
        DFE_SIGN_IN_ISSUER: "https://test-oidc.signin.education.gov.uk:443"
      ) do
        example.run
      end
    end

    it "returns a URL that can be sent to DfE Sign-in to sign the user out of their service" do
      session_with_sign_out_token = double(ActionDispatch::Request::Session)

      allow(session_with_sign_out_token)
        .to receive(:key?)
        .with(:dfe_sign_in_sign_out_token)
        .and_return(true)

      allow(session_with_sign_out_token)
        .to receive(:[])
        .with(:dfe_sign_in_sign_out_token)
        .and_return("a-long-token")

      user_session = described_class.new(session: session_with_sign_out_token)

      result = user_session.sign_out_url

      expect(result).to eq("https://test-oidc.signin.education.gov.uk:443/session/end?id_token_hint=a-long-token&post_logout_redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fdfe%2Fsignout")
    end

    context "when the user has no sign out token" do
      it "redirects the user to the root path" do
        session_without_sign_in_token = double(ActionDispatch::Request::Session)
        allow(session_without_sign_in_token)
          .to receive(:key?)
          .with(:dfe_sign_in_sign_out_token)
          .and_return(false)

        user_session = described_class.new(session: session_without_sign_in_token)

        result = user_session.sign_out_url

        expect(result).to eql(root_path)
      end
    end
  end

  describe "#invalidate_other_user_sessions" do
    after(:each) do
      RedisSessions.redis.flushdb
      RedisSessionLookup.redis.flushdb
    end

    let(:session) do
      double(ActionDispatch::Request::Session, id:
        double(Rack::Session::SessionId, private_id: "2::5347845262539"))
    end

    let(:omniauth_hash) do
      {
        "uid" => "123",
        "credentials" => {
          "id_token" => "456"
        }
      }
    end

    context "when no other session exists for that DfE Sign in user" do
      it "does not delete any pre-existing session data from the Redis session store" do
        user_session = described_class.new(session: session)

        fake_session_redis = MockRedis.new
        allow(RedisSessions).to receive(:redis).and_return(fake_session_redis)
        expect(fake_session_redis).not_to receive(:del)

        user_session.invalidate_other_user_sessions(omniauth_hash: omniauth_hash)
      end

      it "adds a new session lookup" do
        user_session = described_class.new(session: session)

        fake_session_lookup_redis = MockRedis.new
        allow(RedisSessionLookup).to receive(:redis).and_return(fake_session_lookup_redis)
        expect(fake_session_lookup_redis).to receive(:set).with("user_dsi_id:123", "2::5347845262539")

        user_session.invalidate_other_user_sessions(omniauth_hash: omniauth_hash)
      end
    end

    context "when a session already exists for that DfE Sign in user" do
      it "deletes the pre-existing session data" do
        RedisSessions.redis.set("session:2::5347845262539",
          Marshal.dump({"_csrf_token" => "1", "dfe_sign_in_uid" => "123"}))
        RedisSessionLookup.redis.set("user_dsi_id:123", "2::5347845262539")

        user_session = described_class.new(session: session)

        fake_session_redis = MockRedis.new
        allow(RedisSessions).to receive(:redis).and_return(fake_session_redis)
        expect(fake_session_redis).to receive(:del).with("session:2::5347845262539")

        user_session.invalidate_other_user_sessions(omniauth_hash: omniauth_hash)
      end
    end
  end
end
