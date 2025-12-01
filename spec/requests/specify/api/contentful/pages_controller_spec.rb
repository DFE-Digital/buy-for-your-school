RSpec.describe Api::Contentful::PagesController, type: :request do
  let(:contentful_page) do
    fields = {
      "title" => title,
      "body" => "Test body",
      "id" => contentful_id,
      "slug" => slug,
      "sidebar" => "Test page link",
    }
    contentful_entry(fields)
  end

  let(:params) do
    {
      sys: {
        id: contentful_id,
      },
    }
  end

  let(:contentful_id) { "1234" }
  let(:title) { "title" }
  let(:slug) { "slug" }

  let(:auth_token) { ActionController::HttpAuthentication::Token.encode_credentials("test") }
  let(:headers) { { "Authorization" => auth_token } }

  before do
    page_get = instance_double(::Content::Page::Get)
    allow(page_get).to receive(:call).and_return(contentful_page)
    allow(::Content::Page::Get).to receive(:new).and_return(page_get)
  end

  # POST /api/contentful/pages
  it "creates a page" do
    expect(Page.count).to be_zero

    post "/api/contentful/pages",
         params:,
         headers:,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(Page.first.contentful_id).to eql contentful_id
    expect(Page.first.title).to eql title
  end

  # POST /api/contentful/pages
  context "when given an existing page to update" do
    let!(:page) { create(:page) }
    let(:title) { "new title" }
    let(:contentful_id) { page.contentful_id }

    it "updates the page" do
      expect(Page.count).to eq 1

      post "/api/contentful/pages",
           params:,
           headers:,
           as: :json

      expect(response).to have_http_status(:ok)
      expect(Page.count).to eq 1
      expect(Page.first.title).to eql "new title"
      expect(Page.first.contentful_id).to eql contentful_id
    end
  end

  # DELETE /api/contentful/pages
  context "when given an existing page to delete" do
    let!(:page) { create(:page) }
    let(:contentful_id) { page.contentful_id }

    it "deletes the page" do
      expect(Page.count).to eq 1

      delete "/api/contentful/pages/#{page.contentful_id}",
             headers:,
             as: :json

      expect(response).to have_http_status(:ok)
      expect(Page.count).to be_zero
    end
  end
end
