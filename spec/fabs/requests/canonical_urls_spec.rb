require "rails_helper"

RSpec.describe "Canonical URLs", :vcr, type: :request do
  subject { response.body }

  context "when requesting the root path" do
    before { get root_path }

    it { is_expected.to include(canonical_tag) }
  end

  def canonical_tag(path = nil)
    %(<link href="http://www.example.com/#{path}" rel="canonical" />)
  end
end
