require Rails.root.join("db/migrate/20211129120610_update_slugs_and_contentful_ids_in_pages")

RSpec.describe UpdateSlugsAndContentfulIdsInPages do
  include_context "with data migrations"

  let(:previous_version) { 20_211_123_151_744 }
  let(:current_version) { 20_211_129_120_610 }

  it "updates existing page slugs and contentful_ids" do
    Page.new(slug: "next_steps_mfd").save!

    up

    page = Page.first
    expect(page.slug).to eq "next-steps-mfd"
    expect(page.contentful_id).to eq "4a070fp6xrWB0yv1GMC5vQ"
  end
end
