RSpec.describe Emails::CustomerSatisfactionSurvey do
  let(:survey_email) { described_class.new(recipient: double(first_name: "Paige", last_name: "Turner", email: "test@email.com"), reference: "000001", survey_id: "survey1", caseworker_name: "Justin Case") }

  describe "template values" do
    let!(:template_values) { survey_email.personalisation }

    it "includes satisfaction links" do
      very_satisfied_link = template_values[:very_satisfied_link]
      satisfied_link = template_values[:satisfied_link]
      neither_link = template_values[:neither_link]
      dissatisfied_link = template_values[:dissatisfied_link]
      very_dissatisfied_link = template_values[:very_dissatisfied_link]

      expect(very_satisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=very_satisfied$})
      expect(satisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=satisfied$})
      expect(neither_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=neither})
      expect(dissatisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=dissatisfied$})
      expect(very_dissatisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=very_dissatisfied$})
    end

    it "includes case reference" do
      expect(template_values[:reference]).to eq("000001")
    end

    it "includes user's first name" do
      expect(template_values[:first_name]).to eq("Paige")
    end

    it "includes caseworker's name" do
      expect(template_values[:caseworker_name]).to eq("Justin Case")
    end
  end
end
