RSpec.describe Api::Contentful::PagesController, type: :request do
  let(:params) do
    {
      sys: {
        id: contentful_id,
        title: title,
        slug: slug,
      },
    }
  end

  let(:contentful_id) { "1234" }
  let(:title) { "title" }
  let(:slug) { "slug" }

  before do
    has_valid_api_token
  end

  # POST /api/contentful/pages
  it "creates a page" do
    expect(Page.count).to be_zero

    post "/api/contentful/pages",
         params: params,
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
           params: params,
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
             as: :json

      expect(response).to have_http_status(:ok)
      expect(Page.count).to be_zero
    end
  end
end
