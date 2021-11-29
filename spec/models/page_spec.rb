RSpec.describe Page, type: :model do
  describe "attributes" do
    subject(:page) { create(:page) }

    it { is_expected.to be_persisted }

    it "requires unique contentful_id" do
      expect { create(:page, contentful_id: page.contentful_id) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "requires unique slug" do
      expect { create(:page, slug: page.slug) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
