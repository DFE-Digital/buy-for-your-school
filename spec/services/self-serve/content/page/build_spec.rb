RSpec.describe Content::Page::Build do
  subject(:service) { described_class.new(contentful_page:) }

  let(:contentful_page) do
    fields = {
      "title" => "Test page",
      "body" => "Test body",
      "id" => "123",
      "slug" => "/test-page",
      "sidebar" => "Test page link",
    }
    contentful_entry(fields)
  end

  let(:rollbar_info) do
    {
      "title" => "Test page",
      "contentful_id" => "123",
      "slug" => "/test-page",
    }
  end

  describe "#call" do
    context "when the page is new" do
      it "persists the page" do
        expect(Page.count).to be_zero
        expect(service.call).not_to be_nil
        page = Page.first
        expect(page.title).to eq "Test page"
        expect(page.body).to eq "Test body"
        expect(page.contentful_id).to eq "123"
        expect(page.slug).to eq "/test-page"
        expect(page.sidebar).to eq "Test page link"
      end
    end

    context "when the page exists" do
      it "updates the existing page" do
        create(:page, title: "Old page", body: "Old body", contentful_id: "123", slug: "/old-page", sidebar: nil)
        expect(Page.count).to eq 1
        expect(service.call).not_to be_nil
        expect(Page.count).to eq 1
        page = Page.first
        expect(page.title).to eq "Test page"
        expect(page.body).to eq "Test body"
        expect(page.contentful_id).to eq "123"
        expect(page.slug).to eq "/test-page"
        expect(page.sidebar).to eq "Test page link"
      end
    end
  end
end
