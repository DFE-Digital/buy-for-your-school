RSpec.describe Emails::ExitSurvey do
  describe "#self.generate_survey_query_string" do
    it "generates a query string with encoded case reference, school name, and email" do
      query_string = described_class.generate_survey_query_string("000003", "The Good School", "test@email.com")

      expect(query_string).to match(/\?Q_EED=/)
      expect(Base64.decode64(query_string)).to eq "@A\x03{\"case_ref\":\"000003\",\"school_name\":\"The Good School\",\"email\":\"test@email.com\"}"
    end
  end
end
