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
      expect(helper.banner_message).to eq "This is a new service – your <a class=\"govuk-link\" target=\"_blank\" rel=\"noopener\" href=\"https://dferesearch.fra1.qualtrics.com/jfe/form/SV_2gE5Us8IIKxYge2\">feedback</a> will help us to improve it."
    end
  end
end
