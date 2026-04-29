require "rails_helper"

RSpec.describe "API Contentful pages", type: :request do
  let(:api_key) { "contentful-api-key" }
  let(:headers) { { "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(api_key) } }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CONTENTFUL_WEBHOOK_API_KEY").and_return(api_key)
    allow_any_instance_of(Api::Contentful::PagesController).to receive(:track_event)
  end

  it "creates a page when the entry id is sent as params[:id]" do
    contentful_page = instance_double(Contentful::Entry)
    built_page = instance_double(Page, slug: "dynamic-purchasing-systems")
    getter = instance_double(Content::Page::Get, call: contentful_page)
    builder = instance_double(Content::Page::Build, call: built_page)

    allow(Content::Page::Get).to receive(:new).with(entry_id: "page-123").and_return(getter)
    allow(Content::Page::Build).to receive(:new).with(contentful_page:).and_return(builder)

    post "/api/contentful/pages", params: { id: "page-123" }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "OK")
  end

  it "creates a page when the entry id is sent as params[:sys][:id]" do
    contentful_page = instance_double(Contentful::Entry)
    built_page = instance_double(Page, slug: "dynamic-purchasing-systems")
    getter = instance_double(Content::Page::Get, call: contentful_page)
    builder = instance_double(Content::Page::Build, call: built_page)

    allow(Content::Page::Get).to receive(:new).with(entry_id: "page-456").and_return(getter)
    allow(Content::Page::Build).to receive(:new).with(contentful_page:).and_return(builder)

    post "/api/contentful/pages", params: { sys: { id: "page-456" } }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "OK")
  end

  it "destroys a page using the route id" do
    page = create(:page, contentful_id: "page-789")

    delete "/api/contentful/pages/page-789", headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("status" => "OK")
    expect(Page.find_by(id: page.id)).to be_nil
  end

  it "returns unauthorized without a valid token" do
    post "/api/contentful/pages", params: { id: "page-123" }

    expect(response).to have_http_status(:unauthorized)
  end
end
