require "rails_helper"

RSpec.describe Support::ExpanderHelper do
  describe "expander" do
    let(:title) { "Stages" }
    let(:subtitle) { "subtitle" }
    let(:expanded) { true }
    let(:disabled) { false }
    let(:html) { { "data" => "value" } }
    let(:block) { "<p>expander</p>" }

    before do
      allow(helper).to receive(:render)
    end

    it "passes parameters to the view" do
      helper.expander(title:, subtitle:, expanded:, disabled:, html:) { block.html_safe }
      expect(helper).to have_received(:render).with("support/helpers/expander", { title:, subtitle:, expanded:, disabled:, html:, content: block })
    end
  end
end
