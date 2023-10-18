require "rails_helper"

xdescribe "Support::Messages::ReplyForm" do
  let(:agent) { Support::AgentPresenter.new(build(:support_agent)) }
  let(:kase) { create(:support_case) }
  let(:email) { build(:support_email) }
  let(:body) { "<p>Well hello</p>" }
  let(:email_subject) { "subject" }
  let(:default_template) { "default template" }
  let(:default_subject) { "default subject" }
  let(:reply_to_message_double) { double(call: nil) }
  let(:send_new_message_double) { double(call: nil) }
  let(:parser_double) { double(parse: nil) }
  let(:case_ref) { kase.ref }

  before do
    allow(Messages::ReplyToMessage).to receive(:new).and_return(reply_to_message_double)
    allow(Messages::SendNewMessage).to receive(:new).and_return(send_new_message_double)
  end

  describe "#reply_to_email" do
    context "with a template" do
      let(:template) { create(:support_email_template, body: "template body", subject: "template subject") }
      let(:template_id) { template.id }

      before do
        allow(parser_double).to receive(:parse).with(template.body).and_return(template.body)
      end

      context "when sending a reply" do
        before { described_class.new(parser: parser_double, template_id:).reply_to_email(email, kase, agent) }

        it "parses the template body" do
          expect(parser_double).to have_received(:parse).with(template.body)
        end

        it "delegates to ReplyToMessage with template body" do
          expect(Email::DraftReply).to have_received(:new).with(
            replying_to_email: email,
            html_content: template.body,
            template_id:,
            file_attachments: [],
          )
        end
      end

      context "when sending a new message" do
        before do
          described_class.new(
            parser: parser_double,
            template_id:,
            case_ref:,
          ).create_new_message(kase, agent)
        end

        it "parses the template body" do
          expect(parser_double).to have_received(:parse).with(template.body)
        end

        it "delegates to SendNewMessage with template body" do
          expect(send_new_message_double).to have_received(:call).with(
            support_case_id: kase.id,
            message_options: {
              to_recipients: nil,
              cc_recipients: nil,
              bcc_recipients: nil,
              message_text: template.body,
              sender: agent,
              template_id:,
              file_attachments: [],
              subject: "Case #{case_ref} - #{template.subject}",
            },
          )
          expect(send_new_message_double).to have_received(:call).once
        end
      end
    end

    context "without a template" do
      context "with default body" do
        before do
          allow(parser_double).to receive(:parse).with(default_template).and_return(default_template)
        end

        context "when sending a reply" do
          before { described_class.new(parser: parser_double, default_template:).reply_to_email(email, kase, agent) }

          it "parses the default template body" do
            expect(parser_double).to have_received(:parse).with(default_template)
          end

          it "delegates to ReplyToMessage with default body" do
            expect(reply_to_message_double).to have_received(:call).with(
              support_case_id: kase.id,
              reply_options: {
                reply_to_email: email,
                reply_text: default_template,
                sender: agent,
                template_id: nil,
                file_attachments: [],
              },
            )
            expect(reply_to_message_double).to have_received(:call).once
          end
        end

        context "when sending a new message" do
          before do
            described_class.new(
              parser: parser_double,
              default_template:,
              default_subject:,
            ).create_new_message(kase, agent)
          end

          it "parses the default template body" do
            expect(parser_double).to have_received(:parse).with(default_template)
          end

          it "delegates to SendNewMessage with default body and subject" do
            expect(send_new_message_double).to have_received(:call).with(
              support_case_id: kase.id,
              message_options: {
                to_recipients: nil,
                cc_recipients: nil,
                bcc_recipients: nil,
                message_text: default_template,
                sender: agent,
                template_id: nil,
                file_attachments: [],
                subject: default_subject,
              },
            )
            expect(send_new_message_double).to have_received(:call).once
          end
        end
      end

      context "with custom body" do
        context "when sending a reply" do
          before { described_class.new(body:).reply_to_email(email, kase, agent) }

          it "delegates to ReplyToMessage with custom body" do
            expect(reply_to_message_double).to have_received(:call).with(
              support_case_id: kase.id,
              reply_options: {
                reply_to_email: email,
                reply_text: body,
                sender: agent,
                template_id: nil,
                file_attachments: [],
              },
            )
            expect(reply_to_message_double).to have_received(:call).once
          end
        end

        context "when sending a new message" do
          before do
            described_class.new(
              body:,
              subject: email_subject,
            ).create_new_message(kase, agent)
          end

          it "delegates to SendNewMessage with custom body and subject" do
            expect(send_new_message_double).to have_received(:call).with(
              support_case_id: kase.id,
              message_options: {
                to_recipients: nil,
                cc_recipients: nil,
                bcc_recipients: nil,
                message_text: body,
                sender: agent,
                template_id: nil,
                file_attachments: [],
                subject: email_subject,
              },
            )
            expect(send_new_message_double).to have_received(:call).once
          end
        end
      end
    end

    context "with attachments" do
      let(:file_attachment) { fixture_file_upload Rails.root.join("spec/fixtures/gias/example_schools_data.csv"), "text/csv" }
      let(:blob_attachments) { "[{\"blob\": \"1\"}]" }
      let(:processed_file_attachment) { double("processed_file_attachment") }
      let(:processed_blob_attachment) { double("processed_blob_attachment") }
      let(:blob) { double("blob") }
      let(:resolved_blob_attachment) { [double(file: double(blob:))] }

      before do
        allow(Support::Emails::Attachments).to receive(:resolve_blob_attachments).with(JSON.parse(blob_attachments)).and_return(resolved_blob_attachment)
        allow(Support::Messages::Outlook::Reply::Attachment).to receive(:create).with(file_attachment).and_return(processed_file_attachment)
        allow(Support::Messages::Outlook::Reply::Attachment).to receive(:create).with(blob).and_return(processed_blob_attachment)
      end

      context "when sending a reply" do
        before { described_class.new(body:, file_attachments: [file_attachment], blob_attachments:).reply_to_email(email, kase, agent) }

        it "delegates to ReplyToMessage with attachments" do
          expect(reply_to_message_double).to have_received(:call).with(
            support_case_id: kase.id,
            reply_options: {
              reply_to_email: email,
              reply_text: body,
              sender: agent,
              template_id: nil,
              file_attachments: [processed_file_attachment, processed_blob_attachment],
            },
          )
          expect(reply_to_message_double).to have_received(:call).once
        end
      end

      context "when sending a new message" do
        before do
          described_class.new(
            body:,
            subject: email_subject,
            file_attachments: [file_attachment],
            blob_attachments:,
          ).create_new_message(kase, agent)
        end

        it "delegates to SendNewMessage with attachments" do
          expect(send_new_message_double).to have_received(:call).with(
            support_case_id: kase.id,
            message_options: {
              to_recipients: nil,
              cc_recipients: nil,
              bcc_recipients: nil,
              message_text: body,
              sender: agent,
              template_id: nil,
              file_attachments: [processed_file_attachment, processed_blob_attachment],
              subject: email_subject,
            },
          )
          expect(send_new_message_double).to have_received(:call).once
        end
      end
    end

    context "with recipients" do
      let(:to_recipients) { "[\"recipient1\"]" }
      let(:cc_recipients) { "[\"recipient2\"]" }
      let(:bcc_recipients) { "[\"recipient3\"]" }

      context "when sending a new message" do
        before do
          described_class.new(
            to_recipients:,
            cc_recipients:,
            bcc_recipients:,
            body:,
            subject: email_subject,
          ).create_new_message(kase, agent)
        end

        it "delegates to SendNewMessage with recipients" do
          expect(send_new_message_double).to have_received(:call).with(
            support_case_id: kase.id,
            message_options: {
              to_recipients: JSON.parse(to_recipients),
              cc_recipients: JSON.parse(cc_recipients),
              bcc_recipients: JSON.parse(bcc_recipients),
              message_text: body,
              sender: agent,
              template_id: nil,
              file_attachments: [],
              subject: email_subject,
            },
          )
          expect(send_new_message_double).to have_received(:call).once
        end
      end
    end
  end
end
