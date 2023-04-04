require "rails_helper"

RSpec.describe Support::TableSortHelper do
  describe "sortable_th" do
    let(:param) { :attribute }
    let(:title) { "Column" }
    let(:scope) { :sort_column }
    let(:form) { double(sort: { "attribute" => "ascending" }) }
    let(:th_classes) { "class" }
    let(:th_attributes) { { title: "column" } }

    before do
      allow(helper).to receive(:render)
    end

    it "passes parameters to the view" do
      helper.sortable_th(param, title, scope, form, th_classes:, th_attributes:)
      expect(helper).to have_received(:render).with("support/helpers/sortable_th", { param:, title:, scope:, sort: "ascending", sort_order: :asc_desc, th_classes:, th_attributes: })
    end
  end
end
