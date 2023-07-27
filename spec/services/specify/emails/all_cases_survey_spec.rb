RSpec.describe Emails::AllCasesSurvey do
  describe "#personalisation" do
    it "includes the link to the exit survey and satisfcation level links" do
      personalisation = described_class.new(recipient: OpenStruct.new(email: "test@email.com"), reference: "000003", survey_id: "survey1", template: "").personalisation
      very_satisfied_link = personalisation[:very_satisfied_link]
      satisfied_link = personalisation[:satisfied_link]
      neither_link = personalisation[:neither_link]
      dissatisfied_link = personalisation[:dissatisfied_link]
      very_dissatisfied_link = personalisation[:very_dissatisfied_link]

      expect(very_satisfied_link).to match(%r{/all_cases_survey/satisfaction/survey1/edit\?satisfaction_level=very_satisfied$})
      expect(satisfied_link).to match(%r{/all_cases_survey/satisfaction/survey1/edit\?satisfaction_level=satisfied$})
      expect(neither_link).to match(%r{/all_cases_survey/satisfaction/survey1/edit\?satisfaction_level=neither$})
      expect(dissatisfied_link).to match(%r{/all_cases_survey/satisfaction/survey1/edit\?satisfaction_level=dissatisfied$})
      expect(very_dissatisfied_link).to match(%r{/all_cases_survey/satisfaction/survey1/edit\?satisfaction_level=very_dissatisfied$})
    end
  end
end
