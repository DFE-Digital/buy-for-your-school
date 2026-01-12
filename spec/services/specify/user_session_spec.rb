RSpec.describe UserSession do
  subject(:user_session) do
    described_class.new(session:, redirect_url:)
  end

  let(:redirect_url) { "https://ghbs-self-serve.app:123/session/end" }

  let(:session) { instance_double(ActionDispatch::Request::Session) }

  let(:omniauth_hash) do
    {
      "uid" => "123",
      "credentials" => {
        "id_token" => "456",
      },
    }
  end

  describe "#delete!" do
    it "deletes the DfE sign in claim from the session" do
      expect(session).to receive(:delete).with(:dfe_sign_in_uid)
      expect(session).to receive(:delete).with(:dfe_sign_in_sign_out_token)
      user_session.delete!
    end
  end

  describe "#should_be_signed_out_of_dsi?" do
    it "returns true when there is a sign out token" do
      allow(session).to receive(:[]).with(:dfe_sign_in_sign_out_token).and_return("a-long-token")
      expect(user_session.should_be_signed_out_of_dsi?).to be true
    end

    it "returns false when the sign out token value is blank" do
      allow(session).to receive(:[]).with(:dfe_sign_in_sign_out_token).and_return("")
      expect(user_session.should_be_signed_out_of_dsi?).to be false
    end

    it "returns false when there is no sign out token" do
      allow(session).to receive(:[]).with(:dfe_sign_in_sign_out_token).and_return(nil)
      expect(user_session.should_be_signed_out_of_dsi?).to be false
    end
  end

  describe "#sign_out_url" do
    around do |example|
      ClimateControl.modify(DSI_ENV: "test") { example.run }
    end

    it "returns a URL that can be sent to DfE Sign-in to sign the user out of their service" do
      allow(session).to receive(:[]).with(:dfe_sign_in_sign_out_token).and_return("a-long-token")
      expect(user_session.sign_out_url).to eq("https://test-oidc.signin.education.gov.uk/session/end?id_token_hint=a-long-token&post_logout_redirect_uri=https%3A%2F%2Fghbs-self-serve.app%3A123%2Fsession%2Fend")
    end

    context "when the user has no sign out token" do
      it "returns nil" do
        allow(session).to receive(:[]).with(:dfe_sign_in_sign_out_token).and_return(nil)
        expect(user_session.sign_out_url).to be_nil
      end
    end
  end

  describe "#persist_successful_dfe_sign_in_claim!" do
    it "stores the DfE Sign-in UID in the session" do
      expect(session).to receive(:[]=).with(:dfe_sign_in_uid, "123")
      expect(session).to receive(:[]=).with(:dfe_sign_in_sign_out_token, "456")

      user_session.persist_successful_dfe_sign_in_claim!(auth: omniauth_hash)
    end
  end

  describe "#invalidate_other_user_sessions" do
    after do
      RedisSessions.redis.flushdb
      RedisSessionLookup.redis.flushdb
    end

    let(:session) do
      instance_double(ActionDispatch::Request::Session, id:
        instance_double(Rack::Session::SessionId, private_id: "2::5347845262539"))
    end

    context "when no other session exists for that DfE Sign in user" do
      it "does not delete any pre-existing session data from the Redis session store" do
        fake_session_redis = MockRedis.new
        allow(RedisSessions).to receive(:redis).and_return(fake_session_redis)
        expect(fake_session_redis).not_to receive(:del)

        user_session.invalidate_other_user_sessions(auth: omniauth_hash)
      end

      it "adds a new session lookup" do
        fake_session_lookup_redis = MockRedis.new
        allow(RedisSessionLookup).to receive(:redis).and_return(fake_session_lookup_redis)
        expect(fake_session_lookup_redis).to receive(:set).with("user_dsi_id:123", "2::5347845262539")

        user_session.invalidate_other_user_sessions(auth: omniauth_hash)
      end
    end

    context "when a session already exists for that DfE Sign in user" do
      it "deletes the pre-existing session data" do
        RedisSessions.redis.set("session:2::5347845262539",
                                Marshal.dump({ "_csrf_token" => "1", "dfe_sign_in_uid" => "123" }))
        RedisSessionLookup.redis.set("user_dsi_id:123", "2::5347845262539")

        fake_session_redis = MockRedis.new
        allow(RedisSessions).to receive(:redis).and_return(fake_session_redis)
        expect(fake_session_redis).to receive(:del).with("session:2::5347845262539")

        user_session.invalidate_other_user_sessions(auth: omniauth_hash)
      end
    end
  end

  describe "Session store configuration" do
    it "sets expire_after to 8 hours" do
      expect(Rails.application.config.session_options[:expire_after]).to eq(8.hours)
    end
  end
end
