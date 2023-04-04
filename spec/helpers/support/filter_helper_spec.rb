require "rails_helper"

describe Support::FilterHelper do
  let(:key) { :filter_form }
  let(:form) { double("filter_form", filters_selected?: true) }
  let(:params) { { filter_form: { x: 1 } } }

  before { allow(helper).to receive(:params).and_return(params) }

  context "when both filtering key param present, and user has selected in the filter form" do
    it "displays the filter form" do
      expect(helper.toggle_visibility?(key, form)).to eq("govuk-!-display-block")
    end
  end

  context "when only the filtering key param is present but the user has not selected in the form" do
    let(:form) { double("filter_form", filters_selected?: false) }

    it "hides the filter form" do
      expect(helper.toggle_visibility?(key, form)).to eq("govuk-!-display-none")
    end
  end
end
