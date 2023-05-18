require "rails_helper"

RSpec.describe Support::TagBarHelper do
  describe "tag_bar" do
    let(:tags) { [] }
    let(:form_id) { :filter_form }
    let(:preposition) { "about" }

    before do
      allow(helper).to receive(:render)
    end

    it "passes parameters to the view" do
      helper.tag_bar(tags, form_id, preposition:)
      expect(helper).to have_received(:render).with("support/helpers/tag_bar", { tags:, form_id:, preposition: })
    end
  end
end
