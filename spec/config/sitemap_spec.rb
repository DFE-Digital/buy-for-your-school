# spec/tasks/sitemap_spec.rb

require "rails_helper"
require "rake"
require "zlib"

RSpec.describe "sitemap:create", type: :task do
  before do
    Rails.application.load_tasks
    Rake::Task["sitemap:create"].reenable
  end

  after do
    FileUtils.rm_f(sitemap_path)
  end

  let(:sitemap_path) { Rails.root.join("public/sitemap.xml.gz") }
  let(:updated_at) { Time.current }

  let(:category) do
    instance_double(
      FABS::Category,
      slug: "catering",
      updated_at:,
    )
  end

  let(:solution) do
    instance_double(
      Solution,
      slug: "food",
      primary_category: category,
      updated_at:,
    )
  end

  let(:page) do
    instance_double(
      FABS::Page,
      slug: "about",
      updated_at:,
    )
  end

  it "generates the sitemap" do
    allow(FABS::Category).to receive(:all).and_return([category])
    allow(Solution).to receive(:all).and_return([solution])
    allow(FABS::Page).to receive(:all).and_return([page])

    Rake::Task["sitemap:create"].invoke

    expect(File).to exist(sitemap_path)

    sitemap = Zlib::GzipReader.open(sitemap_path, &:read)

    expect(sitemap).to include(
      "/categories/catering",
      "/categories/catering/food",
      "/about",
    )
  end
end
