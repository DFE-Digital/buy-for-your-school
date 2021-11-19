require "rails_helper"

RSpec.describe Page, type: :model do
  describe "attributes" do
    subject(:page) { create(:page) }

    it { is_expected.to be_persisted }

    it "requires a contentful_id" do
      expect { create(:page, contentful_id: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "requires unique contentful_id" do
      expect { create(:page, contentful_id: page.contentful_id) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "requires unique slug" do
      expect { create(:page, slug: page.slug) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "updates routes on slug change" do
      expect(get: "/test-page").not_to be_routable
      page = described_class.create!(slug: "test-page", contentful_id: 123)
      expect(get: "/test-page").to be_routable
      expect(Rails.application).not_to receive(:reload_routes!)
      page.update!(name: "foo")
    end
  end
end
