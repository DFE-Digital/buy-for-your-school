describe Support::SendExitSurveyJob do
  subject(:job) { described_class.new }

  describe "#self.start" do
    context "when there is a survey email delay" do
      around do |example|
        ClimateControl.modify(EXIT_SURVEY_EMAIL_DELAY: "5") do
          example.run
        end
      end

      it "sets the delay" do
        allow(job.class).to receive(:set).with({ wait: 5.minutes }).and_return(job.class)
        expect(job.class).to receive(:perform_later).with("000001")

        job.class.start("000001")
      end
    end

    context "when there is no survey email delay" do
      it "sends the survey immediately" do
        expect(job.class).to receive(:perform_now).with("000001")

        job.class.start("000001")
      end
    end
  end

  describe "#perform" do
    let!(:kase) { create(:support_case, :resolved, ref: "000001", agent: create(:support_agent, first_name: "Kerry", last_name: "Oki")) }
    let(:exit_survey_service) { double("exit_survey_service", call: nil) }

    before do
      allow(Emails::CustomerSatisfactionSurvey).to receive(:new)
        .with(recipient: kase,
              reference: "000001",
              survey_id: instance_of(String),
              caseworker_name: "Kerry Oki")
        .and_return(exit_survey_service)

      job.perform("000001")
    end

    context "when the email has already been sent out" do
      let!(:kase) { create(:support_case, ref: "000001", exit_survey_sent: true) }

      it "does not send the email again" do
        expect(exit_survey_service).not_to have_received(:call)
      end
    end

    context "when the case is not resolved" do
      let!(:kase) { create(:support_case, :opened, ref: "000001", exit_survey_sent: false) }

      it "does not send the email again" do
        expect(exit_survey_service).not_to have_received(:call)
      end
    end

    it "sends an exit survey email to the contact of the specified case" do
      expect(exit_survey_service).to have_received(:call).once
    end

    it "records that the exit survey has been sent" do
      expect(kase.reload.exit_survey_sent).to eq true
    end

    it "creates a case note that the exit survey has been sent" do
      expect(kase.interactions.note.count).to eq 1
      expect(kase.interactions.note.first.body).to eq "The exit survey email has been sent"
    end

    it "creates a customer satisfaction survey with the right initial values" do
      customer_satisfaction_survey = CustomerSatisfactionSurveyResponse.first
      expect(customer_satisfaction_survey.sent_out?).to eq(true)
      expect(customer_satisfaction_survey.survey_sent_at).to be_within(1.second).of(Time.zone.now)
      expect(customer_satisfaction_survey.service_supported_journey?).to eq(true)
      expect(customer_satisfaction_survey.source_exit_survey?).to eq(true)
    end
  end
end
