RSpec.describe Emails::CustomerSatisfactionSurvey do
  let(:survey_email) { described_class.new(recipient: double(first_name: "Paige", last_name: "Turner", email: "test@email.com"), reference: "000001", survey_id: "survey1", caseworker_name: "Justin Case") }

  describe "template values" do
    let!(:template_values) { survey_email.personalisation }

    it "includes satisfaction links" do
      extremely_satisfied_link = template_values[:extremely_satisfied_link]
      very_satisfied_link = template_values[:very_satisfied_link]
      neutral_link = template_values[:neutral_link]
      slightly_satisfied_link = template_values[:slightly_satisfied_link]
      not_satisfied_at_all_link = template_values[:not_satisfied_at_all_link]

      expect(extremely_satisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=extremely_satisfied$})
      expect(very_satisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=very_satisfied$})
      expect(neutral_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=neutral$})
      expect(slightly_satisfied_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=slightly_satisfied$})
      expect(not_satisfied_at_all_link).to match(%r{/customer_satisfaction_surveys/survey1/satisfaction_level/edit\?customer_satisfaction_survey%5Bsatisfaction_level%5D=not_satisfied_at_all$})
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
