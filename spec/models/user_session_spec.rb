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
end
