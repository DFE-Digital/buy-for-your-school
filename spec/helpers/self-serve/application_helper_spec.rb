RSpec.describe ApplicationHelper, type: :helper do
  describe "#banner_tag" do
    it "returns the beta tag by default" do
      # banner.beta.tag
      expect(helper.banner_tag).to eq "beta"
    end
  end

  describe "#banner_message" do
    it "returns the beta message by default" do
      # banner.beta.message
      expect(helper.banner_message).to eq "This is a new service – your <a href=\"mailto:#{ENV['SUPPORT_EMAIL']}\" class=\"govuk-link\">feedback</a> will help us to improve it."
    end
  end

  describe "#footer_message" do
    it "returns the footer message by default" do
      # banner.footer.message
      expect(helper.footer_message).to eq "For privacy information for this service, or to request the deletion of any personal data, email <a href=\"mailto:#{ENV['SUPPORT_EMAIL']}\" class=\"govuk-footer__link\">#{ENV['SUPPORT_EMAIL']}</a>"
    end
  end
end
