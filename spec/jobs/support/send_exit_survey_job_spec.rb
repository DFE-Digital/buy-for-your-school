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
    let!(:kase) { create(:support_case, :resolved, ref: "000001") }
    let(:exit_survey_service) { double("exit_survey_service", call: nil) }

    before do
      allow(Emails::ExitSurvey).to receive(:new)
        .with(recipient: kase,
              reference: "000001",
              survey_id: instance_of(String))
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
  end
end
