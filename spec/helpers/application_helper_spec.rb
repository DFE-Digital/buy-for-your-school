require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#custom_banner_tag_class" do
    it "returns nil" do
      expect(helper.custom_banner_tag_class).to eq(nil)
    end

    context "when PREVIEW_APP is configured to true" do
      around do |example|
        ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
          example.run
        end
      end

      it "returns a css class for preview styling" do
        expect(helper.custom_banner_tag_class).to eq("preview-tag")
      end
    end
  end

  describe "#banner_tag" do
    it "returns the beta tag by default" do
      expect(helper.banner_tag).to eq(I18n.t("banner.beta.tag"))
    end

    context "when PREVIEW_APP is configured to true" do
      around do |example|
        ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
          example.run
        end
      end

      it "returns the preview tag copy" do
        expect(helper.banner_tag).to eq(I18n.t("banner.preview.tag"))
      end
    end
  end

  describe "#banner_message" do
    it "returns the beta message by default" do
      expect(helper.banner_message).to eq(I18n.t("banner.beta.message", support_email: ENV.fetch("SUPPORT_EMAIL")))
    end

    context "when PREVIEW_APP is configured to true" do
      around do |example|
        ClimateControl.modify(CONTENTFUL_PREVIEW_APP: "true") do
          example.run
        end
      end

      it "returns the preview message copy" do
        expect(helper.banner_message).to eq(I18n.t("banner.preview.message"))
      end
    end
  end
end
