require "spec_helper"

describe MicrosoftGraph::ApplicationAuthenticator do
  subject(:authenticator) { described_class.new(client_configuration) }

  let(:client_configuration) do
    MicrosoftGraph::ClientConfiguration.new(
      tenant: "tenant",
      client_id: "client_id",
      client_secret: "client_secret",
      scope: "scope",
      grant_type: "grant_type",
    )
  end

  describe "#get_access_token" do
    let(:api_response) { '{"access_token":"ACCESS_TOKEN","expires_in":5000}' }
    let(:api_response_code) { 200 }

    before do
      stub_request(:post, "https://login.microsoftonline.com/tenant/oauth2/v2.0/token")
        .to_return(body: api_response, status: api_response_code)
    end

    it "makes a request to Azure for an access token" do
      authenticator.get_access_token

      authentication_payload = {
        client_id: client_configuration.client_id,
        client_secret: client_configuration.client_secret,
        scope: client_configuration.scope,
        grant_type: client_configuration.grant_type,
      }

      expect(a_request(:post, "https://login.microsoftonline.com/tenant/oauth2/v2.0/token")
        .with(body: authentication_payload))
        .to(have_been_made.once)
    end

    it "returns the access token" do
      expect(authenticator.get_access_token).to eq("ACCESS_TOKEN")
    end

    it "records the token expiry" do
      authenticator.get_access_token
      expect(authenticator.send(:access_token_expiry)).to be_within(1.second).of(Time.now + 5000)
    end

    context "when an access token has already been recorded" do
      context "when that access token will not expire for at least 10 seconds" do
        before do
          authenticator.instance_variable_set(:@access_token, "VALID_ACCESS_TOKEN")
          authenticator.instance_variable_set(:@access_token_expiry, Time.now + 60)
        end

        it "returns the existing access token" do
          expect(authenticator.get_access_token).to eq("VALID_ACCESS_TOKEN")
        end
      end

      context "when the access token will expire within the next 10 seconds" do
        before do
          authenticator.instance_variable_set(:@access_token, "INVALID_ACCESS_TOKEN")
          authenticator.instance_variable_set(:@access_token_expiry, Time.now + 1)
        end

        it "returns a new access token from the server" do
          expect(authenticator.get_access_token).to eq("ACCESS_TOKEN")
        end
      end

      context "when the access token has already expired" do
        before do
          authenticator.instance_variable_set(:@access_token, "INVALID_ACCESS_TOKEN")
          authenticator.instance_variable_set(:@access_token_expiry, Time.now - 100)
        end

        it "returns a new access token from the server" do
          expect(authenticator.get_access_token).to eq("ACCESS_TOKEN")
        end
      end
    end

    context "when the response is not 200" do
      let(:api_response_code) { 400 }

      it "raises a AuthenticationFailureError with details of the error included" do
        expect { authenticator.get_access_token }.to raise_error(
          described_class::AuthenticationFailureError,
        )
      end
    end
  end
end
