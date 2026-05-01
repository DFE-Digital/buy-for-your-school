require "rails_helper"

RSpec.describe PagesController, type: :controller do
  describe "GET #show" do
    let(:deprecated_slug) { "deprecated-page" }
    let(:db_page) { create(:page, slug: deprecated_slug, body: "# DB page", sidebar: nil) }
    let(:fabs_page) { instance_double(FABS::Page, title: "FABS page", parent: nil) }

    before do
      stub_const("#{described_class}::DEPRECATED_GHBS_CONTENTFUL_PAGES", [deprecated_slug])
      allow(Flipper).to receive(:enabled?).and_call_original
    end

    context "when the deprecation flag is enabled for the slug" do
      before do
        allow(Flipper).to receive(:enabled?).with(:deprecate_ghbs_contentful).and_return(true)
        allow(Page).to receive(:find_by)
        allow(FABS::Page).to receive(:find_by_slug!).with(deprecated_slug).and_return(fabs_page)
      end

      it "skips the Page model lookup and renders the FABS page" do
        get :show, params: { slug: deprecated_slug }

        expect(Page).not_to have_received(:find_by)
        expect(FABS::Page).to have_received(:find_by_slug!).with(deprecated_slug)
        expect(response).to render_template("fabs/pages/show")
      end
    end

    context "when the deprecation flag is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:deprecate_ghbs_contentful).and_return(false)
        allow(FABS::Page).to receive(:find_by_slug!)
      end

      it "uses the Page model branch" do
        db_page

        get :show, params: { slug: deprecated_slug }

        expect(FABS::Page).not_to have_received(:find_by_slug!)
        expect(response).to render_template("pages/show")
      end
    end
  end
end
