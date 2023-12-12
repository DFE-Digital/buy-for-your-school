require "rails_helper"

describe CustomerSatisfactionSurveyResponse do
  subject(:survey_response) { described_class.new }

  describe "Validations" do
    it "is not valid without a satisfaction level" do
      expect(survey_response).not_to be_valid(:satisfaction_level)
      expect(survey_response.errors.messages[:satisfaction_level]).to eq(["Select how satisfied you are with this service"])
    end

    it "is not valid without an easy to use rating" do
      expect(survey_response).not_to be_valid(:easy_to_use_rating)
      expect(survey_response.errors.messages[:easy_to_use_rating]).to eq(["Select how strongly you agree that this service was easy to use"])
    end

    it "is not valid without answers to 'helped how'" do
      expect(survey_response).not_to be_valid(:helped_how)
      expect(survey_response.errors.messages[:helped_how]).to eq(["Select how this service has helped you"])
    end

    it "is not valid when 'helped how' has unrecognised answers" do
      survey_response.helped_how << "unknown"
      expect(survey_response).not_to be_valid(:helped_how)
      expect(survey_response.errors.messages[:helped_how]).to eq(["is not included in the list"])
    end

    it "is not valid when 'helped how' is answered with 'other' and is missing 'helped_how_other' text" do
      survey_response.helped_how << "other"
      expect(survey_response).not_to be_valid(:helped_how)
      expect(survey_response.errors.messages[:helped_how_other]).to eq(["Tell us how else this service has helped you"])
    end

    it "is not valid without a clear to use rating" do
      expect(survey_response).not_to be_valid(:clear_to_use_rating)
      expect(survey_response.errors.messages[:clear_to_use_rating]).to eq(["Select how strongly you agree that it was clear what you could use this service to do"])
    end

    it "is not valid without a recommendation likelihood rating" do
      expect(survey_response).not_to be_valid(:recommendation_likelihood)
      expect(survey_response.errors.messages[:recommendation_likelihood]).to eq(["Select how likely you are to recommend us to a colleague on a scale of 0 to 10", "is not included in the list"])
    end

    it "is not valid with a recommendation likelihood rating that is outside the 0-10 range" do
      survey_response.recommendation_likelihood = 15
      expect(survey_response).not_to be_valid(:recommendation_likelihood)
      expect(survey_response.errors.messages[:recommendation_likelihood]).to eq(["is not included in the list"])
    end

    it "is not valid without a research opt in choice" do
      expect(survey_response).not_to be_valid(:research_opt_in)
      expect(survey_response.errors.messages[:research_opt_in]).to eq(["Select whether you would like to participate in research"])
    end

    it "is not valid without an email for research when opted in for research" do
      survey_response.research_opt_in = true
      expect(survey_response).not_to be_valid(:research_opt_in)
      expect(survey_response.errors.messages[:research_opt_in_email]).to eq(["Provide your email address"])
    end

    it "is not valid without a job title for research when opted in for research" do
      survey_response.research_opt_in = true
      expect(survey_response).not_to be_valid(:research_opt_in)
      expect(survey_response.errors.messages[:research_opt_in_job_title]).to eq(["Provide your job title"])
    end
  end

  describe "Callbacks" do
    it "clears blank values from 'helped_how' before validation" do
      survey_response.helped_how = ["", "saved_money"]
      survey_response.validate
      expect(survey_response.helped_how).to eq(%w[saved_money])
    end

    it "clears 'helped_how_other' if 'helped_how' has no 'other' when saving" do
      survey_response.helped_how = %w[saved_money]
      survey_response.helped_how_other = "helped in various ways"
      survey_response.save!
      expect(survey_response.helped_how_other).to be_nil
    end

    it "clears research opt in details if opted out of research when saving" do
      survey_response.research_opt_in = false
      survey_response.research_opt_in_email = "test@email.com"
      survey_response.research_opt_in_job_title = "job"
      survey_response.save!
      expect(survey_response.research_opt_in_email).to be_nil
      expect(survey_response.research_opt_in_job_title).to be_nil
    end
  end

  describe "Starting a survey" do
    it "records the started_at date" do
      survey_response.start_survey!
      expect(survey_response.reload.survey_started_at).to be_within(1.second).of(Time.zone.now)
    end

    it "sets the status to in progress" do
      survey_response.start_survey!
      expect(survey_response.reload).to be_in_progress
    end

    context "when the start date has already been recorded" do
      before { survey_response.update(survey_started_at: 2.days.ago) }

      it "does not update the date again" do
        expect { survey_response.start_survey! }.not_to change(survey_response, :survey_started_at)
      end
    end
  end

  describe "Completing a survey" do
    it "records the completed_at date" do
      survey_response.complete_survey!
      expect(survey_response.reload.survey_completed_at).to be_within(1.second).of(Time.zone.now)
    end

    it "sets the status to completed" do
      survey_response.complete_survey!
      expect(survey_response.reload).to be_completed
    end

    context "when the completed date has already been recorded" do
      before { survey_response.update(survey_completed_at: 2.days.ago) }

      it "does not update the date again" do
        expect { survey_response.complete_survey! }.not_to change(survey_response, :survey_completed_at)
      end
    end
  end
end
