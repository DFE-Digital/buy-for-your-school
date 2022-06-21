RSpec.describe Emails::ExitSurvey do
  describe "#personalisation" do
    it "includes a query string with encoded case reference, school name, and email" do
      personalisation = described_class.new(recipient: OpenStruct.new(email: "test@email.com"), reference: "000003", school_name: "The Good School").personalisation
      query_string = personalisation[:survey_query_string]

      expect(query_string).to match(/\?Q_EED=/)
      expect(Base64.decode64(query_string)).to eq "@A\x03{\"case_ref\":\"000003\",\"school_name\":\"The Good School\",\"email\":\"test@email.com\"}"
    end
  end
end
