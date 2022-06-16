describe Support::SendExitSurveyJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    let!(:kase) { create(:support_case, ref: "000001") }
    let(:exit_survey_service) { double("exit_survey_service", call: nil) }

    before do
      allow(Emails::ExitSurvey).to receive(:new)
        .with(recipient: OpenStruct.new(
          email: "school@email.co.uk",
          first_name: "School",
          last_name: "Contact",
          full_name: "School Contact",
        ),
              variables: {
                survey_query_string: /\?Q_EED=eyJjYXNlX3JlZiI6IjAwMDAwMSIsInNjaG9vbF9uYW1lIjoiU2Nob29sICM/,
              },
              reference: "000001")
        .and_return(exit_survey_service)

      job.perform("000001")
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
