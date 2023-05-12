require "rails_helper"

describe Support::EmailTemplatePresenter do
  subject(:presenter) { described_class.new(template, parser) }

  let(:parser) { nil }

  describe "#groups" do
    let(:group) { create(:support_email_template_group) }
    let(:template) { create(:support_email_template, group:) }

    it "returns the hierarchy of groups" do
      allow(group).to receive(:hierarchy).and_return(nil)
      presenter.groups
      expect(group).to have_received(:hierarchy)
    end
  end

  describe "#stage" do
    let(:template) { create(:support_email_template, stage:) }

    context "when there is a stage" do
      let(:stage) { 0 }

      it "returns the formatted stage value" do
        expect(presenter.stage).to eq("Stage 0")
      end
    end

    context "when there is no stage" do
      let(:stage) { nil }

      it "returns nil" do
        expect(presenter.stage).to be_nil
      end
    end
  end

  describe "#body_parsed" do
    let(:template) { create(:support_email_template) }
    let(:parser) { double("parser") }

    before do
      allow(parser).to receive(:parse).with("Test email template body")
      presenter.body_parsed
    end

    it "calls on the parser to parse the body" do
      expect(parser).to have_received(:parse).with("Test email template body")
    end
  end
end
