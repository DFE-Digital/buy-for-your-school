require "spec_helper"

describe MsoftGraphApi::ClientSession do
  subject(:client_session) { described_class.new(access_token) }

  let(:access_token) { "ACCESS_TOKEN" }
  let(:endpoint) { "https://graph.microsoft.com/v1.0/test/endpoint" }

  describe "#graph_api_get" do
    let(:api_response) { '{"value":[{"displayName":"testResponse"}]}' }
    let(:api_response_code) { 200 }

    before { stub_request(:get, endpoint).to_return(body: api_response, status: api_response_code) }

    it "returns the response from the API" do
      expect(client_session.graph_api_get("test/endpoint")).to eq(JSON.parse(api_response))
    end

    it "makes a GET request to the graph API on the given resource path, supplying authentication headers" do
      client_session.graph_api_get("test/endpoint")

      expect(a_request(:get, endpoint)
        .with(headers: { "Authorization" => "Bearer #{access_token}" }))
        .to(have_been_made.once)
    end

    context "when the response is not 2XX" do
      let(:api_response_code) { 404 }
      let(:api_response) { '{"error":{"code":"ResourceNotFound","message":"Resource could not be discovered."}}' }

      it "raises a GraphRequestFailedError with details of the error included" do
        expect { client_session.graph_api_get("test/endpoint") }.to raise_error(
          MsoftGraphApi::ClientSession::GraphRequestFailedError,
          "Code: ResourceNotFound, Message: Resource could not be discovered.",
        )
      end
    end
  end

  describe "#graph_api_post" do
    let(:request_body) { { hello: "world" } }
    let(:api_response) { '{"value":[{"displayName":"testResponse"}]}' }
    let(:api_response_code) { 200 }

    before { stub_request(:post, endpoint).to_return(body: api_response, status: api_response_code) }

    it "returns the response from the API" do
      expect(client_session.graph_api_post("test/endpoint", request_body)).to eq(JSON.parse(api_response))
    end

    it "makes a POST request to the graph API on the given resource path, supplying authentication headers" do
      client_session.graph_api_post("test/endpoint", request_body)

      expect(a_request(:post, endpoint)
        .with(body: request_body, headers: { "Authorization" => "Bearer #{access_token}" }))
        .to(have_been_made.once)
    end

    context "when the response is not 2XX" do
      let(:api_response_code) { 404 }
      let(:api_response) { '{"error":{"code":"ResourceNotFound","message":"Resource could not be discovered."}}' }

      it "raises a GraphRequestFailedError with details of the error included" do
        expect { client_session.graph_api_post("test/endpoint", request_body) }.to raise_error(
          MsoftGraphApi::ClientSession::GraphRequestFailedError,
          "Code: ResourceNotFound, Message: Resource could not be discovered.",
        )
      end
    end
  end

  describe ".new_application_session" do
    let(:client_configuration) do
      MsoftGraphApi::ClientConfiguration.new(
        tenant: "tenant",
        client_id: "client_id",
        client_secret: "client_secret",
        scope: "scope",
        grant_type: "grant_type",
      )
    end

    let(:api_response) { '{"access_token":"ACCESS_TOKEN"}' }
    let(:api_response_code) { 200 }

    before do
      stub_request(:post, "https://login.microsoftonline.com/tenant/oauth2/v2.0/token")
        .to_return(body: api_response, status: api_response_code)
    end

    it "makes a request to Azure for an access token" do
      described_class.new_application_session(client_configuration)

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

    it "returns a new session with the access token set" do
      session = described_class.new_application_session(client_configuration)
      expect(session.access_token).to eq("ACCESS_TOKEN")
    end

    context "when the response is not 200" do
      let(:api_response_code) { 400 }

      it "raises a AuthenticationFailureError with details of the error included" do
        expect { described_class.new_application_session(client_configuration) }.to raise_error(
          MsoftGraphApi::ClientSession::AuthenticationFailureError,
        )
      end
    end
  end
end
