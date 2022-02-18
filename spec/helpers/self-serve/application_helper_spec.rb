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
      # TODO: update to link to contact form
      expect(helper.banner_message).to eq "This is a new service – your <a class=\"govuk-link\" href=\"/feedback/new\">feedback</a> will help us to improve it."
    end
  end
end
