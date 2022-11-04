require "rails_helper"

describe AllCasesSurveyResponse do
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
        expect { response.start_survey! }.not_to change(response, :survey_started_at)
      end
    end
  end

  describe "Sending a survey" do
    it "records the sent_at date" do
      response.send_survey!
      expect(response.reload.survey_sent_at).to be_within(1.second).of(Time.zone.now)
    end

    it "sets the status to be sent out" do
      response.send_survey!
      expect(response.reload).to be_sent_out_status
    end

    context "when the sent date has already been recorded" do
      before { response.update(survey_sent_at: 2.days.ago) }

      it "does not update the date again" do
        expect { response.send_survey! }.not_to change(response, :survey_sent_at)
      end
    end
  end

  describe "Completing a survey" do
    it "records the completed_at date" do
      response.complete_survey!
      expect(response.reload.survey_completed_at).to be_within(1.second).of(Time.zone.now)
    end

    it "sets the status to be completed" do
      response.complete_survey!
      expect(response.reload).to be_completed_status
    end

    context "when the completed date has already been recorded" do
      before { response.update(survey_completed_at: 2.days.ago) }

      it "does not update the date again" do
        expect { response.complete_survey! }.not_to change(response, :survey_completed_at)
      end
    end
  end
end
