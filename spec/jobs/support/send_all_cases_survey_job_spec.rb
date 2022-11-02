describe Support::SendAllCasesSurveyJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "#perform_later" do
    let!(:kase) { create(:support_case, ref: "000001", state: case_state) }
    let(:all_cases_survey_service) { double("all_cases_survey_service", call: nil) }

    context "when the case is open" do
      let(:case_state) { "opened" }

      before do
        allow(Emails::AllCasesSurveyOpen).to receive(:new)
          .with(recipient: kase,
                reference: "000001",
                survey_id: instance_of(String))
          .and_return(all_cases_survey_service)

        job.perform_later("000001")
        perform_enqueued_jobs
      end

      it "enqueues a job asynchronously on the support queue" do
        expect { job.perform_later("000001") }.to have_enqueued_job.on_queue("support")
      end

      it "sends a survey email to the contact of the specified case" do
        expect(all_cases_survey_service).to have_received(:call).once
      end

      it "creates a case note that the exit survey has been sent" do
        expect(kase.interactions.note.count).to eq 1
        expect(kase.interactions.note.first.body).to eq "The survey for open cases email has been sent"
      end

      it "creates a survey response with the status 'sent_out'" do
        expect(AllCasesSurveyResponse.first.status).to eq "sent_out"
      end
    end

    context "when the case is on hold" do
      let(:case_state) { "on_hold" }

      before do
        allow(Emails::AllCasesSurveyOpen).to receive(:new)
          .with(recipient: kase,
                reference: "000001",
                survey_id: instance_of(String))
          .and_return(all_cases_survey_service)

        job.perform_later("000001")
        perform_enqueued_jobs
      end

      it "enqueues a job asynchronously on the support queue" do
        expect { job.perform_later("000001") }.to have_enqueued_job.on_queue("support")
      end

      it "sends a survey email to the contact of the specified case" do
        expect(all_cases_survey_service).to have_received(:call).once
      end

      it "creates a case note that the exit survey has been sent" do
        expect(kase.interactions.note.count).to eq 1
        expect(kase.interactions.note.first.body).to eq "The survey for open cases email has been sent"
      end

      it "creates a survey response with the status 'sent_out'" do
        expect(AllCasesSurveyResponse.first.status).to eq "sent_out"
      end
    end

    context "when the case is resolved" do
      let(:case_state) { "resolved" }

      before do
        allow(Emails::AllCasesSurveyResolved).to receive(:new)
          .with(recipient: kase,
                reference: "000001",
                survey_id: instance_of(String))
          .and_return(all_cases_survey_service)

        job.perform_later("000001")
        perform_enqueued_jobs
      end

      it "enqueues a job asynchronously on the support queue" do
        expect { job.perform_later("000001") }.to have_enqueued_job.on_queue("support")
      end

      it "sends a survey email to the contact of the specified case" do
        expect(all_cases_survey_service).to have_received(:call).once
      end

      it "creates a case note that the exit survey has been sent" do
        expect(kase.interactions.note.count).to eq 1
        expect(kase.interactions.note.first.body).to eq "The survey for resolved cases email has been sent"
      end

      it "creates a survey response with the status 'sent_out'" do
        expect(AllCasesSurveyResponse.first.status).to eq "sent_out"
      end
    end

    context "when the case is in a different state" do
      let(:case_state) { "initial" }

      it "throws an error" do
        expect { job.new.perform("000001") }.to raise_error(Support::SendAllCasesSurveyJob::UnsupportedCaseStateError, "Case 000001 is in an unsupported state: initial")
      end
    end
  end
end
