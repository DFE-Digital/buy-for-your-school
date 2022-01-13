require "spec_helper"

describe MicrosoftGraph::ClientSession do
  subject(:client_session) { described_class.new(authenticator) }

  let(:authenticator) { double(get_access_token: access_token) }
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
          MicrosoftGraph::ClientSession::GraphRequestFailedError,
          "Code: ResourceNotFound, Message: Resource could not be discovered.",
        )
      end
    end

    context "when the response is paginated" do
      let(:api_response) { '{"value":[{"displayName":"testResponse1"}],"@odata.nextLink":"https://api.endpoint.com?page=2"}' }
      let(:page_2_response) { '{"value":[{"displayName":"testResponse2"}],"@odata.nextLink":"https://api.endpoint.com?page=3"}' }
      let(:page_3_response) { '{"value":[{"displayName":"testResponse3"}]}' }

      before do
        stub_request(:get, "https://api.endpoint.com?page=2").to_return(body: page_2_response, status: 200)
        stub_request(:get, "https://api.endpoint.com?page=3").to_return(body: page_3_response, status: 200)
      end

      it "calls each page and returns the combined results" do
        response = client_session.graph_api_get("test/endpoint")

        expect(response["value"]).to match_array([
          { "displayName" => "testResponse1" },
          { "displayName" => "testResponse2" },
          { "displayName" => "testResponse3" },
        ])
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
          MicrosoftGraph::ClientSession::GraphRequestFailedError,
          "Code: ResourceNotFound, Message: Resource could not be discovered.",
        )
      end
    end
  end

  describe "#graph_api_patch" do
    let(:request_body) { { hello: "world" }.to_json }
    let(:api_response) { '{"value":[{"displayName":"testResponse"}]}' }
    let(:api_response_code) { 200 }

    before { stub_request(:patch, endpoint).to_return(body: api_response, status: api_response_code) }

    it "returns the response from the API" do
      expect(client_session.graph_api_patch("test/endpoint", request_body)).to eq(JSON.parse(api_response))
    end

    it "makes a PATCH request to the graph API on the given resource path, supplying authentication headers" do
      client_session.graph_api_patch("test/endpoint", request_body)

      expect(a_request(:patch, endpoint)
        .with(body: request_body, headers: { "Authorization" => "Bearer #{access_token}" }))
        .to(have_been_made.once)
    end

    context "when the response is not 2XX" do
      let(:api_response_code) { 404 }
      let(:api_response) { '{"error":{"code":"ResourceNotFound","message":"Resource could not be discovered."}}' }

      it "raises a GraphRequestFailedError with details of the error included" do
        expect { client_session.graph_api_patch("test/endpoint", request_body) }.to raise_error(
          MicrosoftGraph::ClientSession::GraphRequestFailedError,
          "Code: ResourceNotFound, Message: Resource could not be discovered.",
        )
      end
    end
  end
end
