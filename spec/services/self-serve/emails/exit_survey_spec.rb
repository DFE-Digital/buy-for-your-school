RSpec.describe Emails::ExitSurvey do
  describe "#personalisation" do
    it "includes the link to the exit survey" do
      personalisation = described_class.new(recipient: OpenStruct.new(email: "test@email.com"), reference: "000003", survey_id: "survey1").personalisation
      exit_survey_link = personalisation[:exit_survey_link]

      expect(exit_survey_link).to match(%r{/exit_survey/start/survey1$})
    end
  end
end
