require "rails_helper"

RSpec.describe Zendesk::Client do
  subject(:client) do
    described_class.new(
      subdomain: "example",
      app_id: "APP_ID",
      app_secret_key: "APP_SECRET",
      brand_id: "123",
    )
  end

  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:token_request) { stub_request(:post, "https://example.zendesk.com/oauth/tokens") }

  before do
    allow(Rails).to receive(:cache).and_return(cache)
    cache.clear
    token_request
      .with(body: hash_including(
        grant_type: "client_credentials",
        client_id: "APP_ID",
        client_secret: "APP_SECRET",
        scope: "account_settings:read read write",
        expires_in: 1_800,
      ))
      .to_return(status: 201, body: { access_token: "ACCESS_TOKEN", expires_in: 1_800 }.to_json)
  end

  describe "#ticket_form_fields" do
    it "returns the form and its field definitions" do
      stub_request(:get, "https://example.zendesk.com/api/v2/ticket_forms/456")
        .with(headers: { "Authorization" => "Bearer ACCESS_TOKEN" })
        .to_return(status: 200, body: { ticket_form: { id: 456, ticket_field_ids: [1, 2] } }.to_json)
      stub_request(:get, "https://example.zendesk.com/api/v2/ticket_fields/show_many?ids=1%2C2")
        .with(headers: { "Authorization" => "Bearer ACCESS_TOKEN" })
        .to_return(status: 200, body: { ticket_fields: [{ "id" => 1 }, { "id" => 2 }] }.to_json)

      expect(client.ticket_form_fields(ticket_form_id: 456)).to eq(
        "ticket_form" => { "id" => 456, "ticket_field_ids" => [1, 2] },
        "ticket_fields" => [{ "id" => 1 }, { "id" => 2 }],
      )
    end
  end

  describe "#ticket_forms" do
    it "returns the ticket forms" do
      stub_request(:get, "https://example.zendesk.com/api/v2/ticket_forms")
        .with(headers: { "Authorization" => "Bearer ACCESS_TOKEN" })
        .to_return(status: 200, body: { ticket_forms: [{ "id" => 456 }] }.to_json)

      expect(client.ticket_forms).to eq([{ "id" => 456 }])
    end
  end

  describe "#create_ticket" do
    it "creates a ticket for the configured brand and returns its id" do
      stub_request(:post, "https://example.zendesk.com/api/v2/tickets")
        .with(
          headers: { "Authorization" => "Bearer ACCESS_TOKEN" },
          body: {
            ticket: {
              subject: "A request",
              comment: { body: "Please help" },
              brand_id: "123",
              ticket_form_id: 456,
              custom_fields: [{ id: 99, value: "value" }],
            },
          }.to_json,
        )
        .to_return(status: 201, body: { ticket: { id: 789 } }.to_json)

      expect(
        client.create_ticket(
          subject: "A request",
          comment: "Please help",
          ticket_form_id: 456,
          custom_fields: [{ id: 99, value: "value" }],
        ),
      ).to eq(789)
    end
  end

  it "caches the OAuth token for subsequent requests" do
    stub_request(:get, "https://example.zendesk.com/api/v2/ticket_forms/456")
      .with(headers: { "Authorization" => "Bearer ACCESS_TOKEN" })
      .to_return(status: 200, body: { ticket_form: { id: 456, ticket_field_ids: [] } }.to_json)

    2.times { client.ticket_form(ticket_form_id: 456) }

    expect(token_request).to have_been_requested.once
  end
end
