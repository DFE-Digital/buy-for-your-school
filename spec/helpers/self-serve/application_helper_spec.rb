# TODO: strip I18n

RSpec.describe ApplicationHelper, type: :helper do
  describe "#banner_tag" do
    it "returns the beta tag by default" do
      expect(helper.banner_tag).to eq I18n.t("banner.beta.tag")
    end
  end

  describe "#banner_message" do
    it "returns the beta message by default" do
      expect(helper.banner_message).to eq I18n.t("banner.beta.message", support_email: ENV.fetch("SUPPORT_EMAIL"))
    end
  end

  describe "#footer_message" do
    it "returns the footer message by default" do
      expect(helper.footer_message).to eq I18n.t("banner.footer.message", support_email: ENV.fetch("SUPPORT_EMAIL"))
    end
  end
end
