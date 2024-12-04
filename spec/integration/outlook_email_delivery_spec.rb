require "rails_helper"

describe "Outlook emails delivery integration" do
  subject(:draft_email) do
    Email::Draft.new(
      ticket:,
      subject: subject_line,
      default_subject:,
      template_id:,
      html_content:,
      default_content:,
    )
  end

  let(:ticket) { create(:support_case, ref: "000999") }
  let(:agent) { create(:support_agent, first_name: "Test", last_name: "Agent") }
  let(:subject_line) { nil }
  let(:default_subject) { nil }
  let(:template_id) { nil }
  let(:html_content) { "content here" }
  let(:default_content) { nil }
  let(:file_attachments) { [] }
  let(:blob_attachments) { "[]" }

  before { Current.actor = agent }

  describe "email body" do
    context "when no template has been chosen" do
      let(:template_id) { nil }

      context "and html content has been specified" do
        let(:html_content) { "This content has been specified by the user" }

        it "uses the specified html content" do
          expect(draft_email.body).to eq("This content has been specified by the user")
        end

        context "and the html content contains variables" do
          let(:html_content) { "This content has a variable, {{caseworker_full_name}}" }

          it "replaces the variables with the appropriate values" do
            expect(draft_email.body).to eq("This content has a variable, Test Agent")
          end
        end
      end
    end

    context "when a template has been chosen and html_content is empty" do
      let(:template_id) { create(:support_email_template, body: "This is content from the template").id }
      let(:html_content) { nil }

      it "uses the content from the template" do
        expect(draft_email.body).to eq("This is content from the template")
      end

      context "and the template contains variables" do
        let(:template_id) { create(:support_email_template, body: "This is content from the template, {{caseworker_full_name}}").id }

        it "replaces the variables with the appropriate values" do
          expect(draft_email.body).to eq("This is content from the template, Test Agent")
        end
      end
    end

    context "when no template has been chosen, html_content is empty but a default_content is specified" do
      let(:template_id) { nil }
      let(:html_content) { nil }
      let(:default_content) { "This is content from the default content" }

      it "uses the content from the default_content" do
        expect(draft_email.body).to eq("This is content from the default content")
      end

      context "and the default content contains variables" do
        let(:default_content) { "This is content from the default content, {{caseworker_full_name}}" }

        it "replaces the variables with the appropriate values" do
          expect(draft_email.body).to eq("This is content from the default content, Test Agent")
        end
      end
    end
  end

  describe "subject line" do
    context "when a subject line has been specifed" do
      let(:subject_line) { "User specified subject line" }

      it "uses the specified subject" do
        expect(draft_email.subject).to eq("User specified subject line")
      end

      context "and the subject contains variables" do
        let(:subject_line) { "User specified subject line FIO: {{caseworker_full_name}}" }

        it "replaces the variables with the appropriate values" do
          expect(draft_email.subject).to eq("User specified subject line FIO: Test Agent")
        end
      end
    end

    context "when a template has been specified and none specifed by the user" do
      let(:template_id) { create(:support_email_template, subject: "Subject line from the template").id }
      let(:subject_line) { nil }

      it "uses the subject from the template prefixed with the ticket email prefix" do
        expect(draft_email.subject).to eq("Case 000999 - Subject line from the template")
      end

      context "and the ticket is a framework evaluation" do
        let(:ticket) { create(:frameworks_evaluation, reference: "FE999") }

        it "uses the subject from the template prefixed with the ticket email prefix" do
          expect(draft_email.subject).to eq("[FE999] - Subject line from the template")
        end
      end

      context "and the template subject contains variables" do
        let(:template_id) { create(:support_email_template, subject: "Subject line from the template FIO: {{caseworker_full_name}}").id }

        it "replaces the variables with the appropriate values" do
          expect(draft_email.subject).to eq("Case 000999 - Subject line from the template FIO: Test Agent")
        end
      end
    end

    context "when no template has been chosen, no subject set by the user but a default subject has been set" do
      let(:template_id) { nil }
      let(:subject_line) { nil }
      let(:default_subject) { "Default subject line" }

      it "uses the specified default subject line" do
        expect(draft_email.subject).to eq("Default subject line")
      end

      context "and the default subject contains variables" do
        let(:default_subject) { "Default subject line FIO: {{caseworker_full_name}}" }

        it "replaces the variables with the appropriate values" do
          expect(draft_email.subject).to eq("Default subject line FIO: Test Agent")
        end
      end
    end
  end
end
