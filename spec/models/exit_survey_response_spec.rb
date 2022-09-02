require "rails_helper"

describe ExitSurveyResponse do
  subject(:response) { described_class.new(status: :sent_out) }

  describe "Starting a survey" do
    it "records the started_at date" do
      response.start_survey!
      expect(response.reload.survey_started_at).to be_within(1.second).of(Time.zone.now)
    end

    it "sets the status to be in progress" do
      response.start_survey!
      expect(response.reload).to be_in_progress_status
    end

    context "when the start date has already been recorded" do
      before { response.update(survey_started_at: 2.days.ago) }

      it "does not update the date again" do
        expect { response.start_survey! }.not_to change { response.reload.survey_started_at }
      end
    end
  end
end
