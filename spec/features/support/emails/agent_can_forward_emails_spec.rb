describe "Agent can forward an email", :js, bullet: :skip do
  include_context "with an agent"
  include_context "with a support case and email"

  let(:email) do
    create(:support_email, origin, ticket: support_case, subject: "VAT Certificate - #{support_case.ref}")
  end

  let(:valid_email) { "test@example.com" }

  def message_double(body)
    double(
      id: "1",
      subject: "",
      body: double(content: body),
      unique_body: double(content: body),
      from: double(email_address: double(address: "", name: "")),
      to_recipients: [double(email_address: double(address: valid_email, name: "Jon"))],
      cc_recipients: [],
      bcc_recipients: [],
      sent_date_time: Time.zone.now,
      received_date_time: nil,
      internet_message_id: "",
      conversation_id: "1",
      has_attachments: false,
      is_read: false,
      is_draft: false,
      in_reply_to_id: "",
    )
  end

  context "when there is an email from the supplier" do
    before do
      allow(Email).to receive(:cache_message).and_return(double.as_null_object)
      allow(MicrosoftGraph).to receive(:client).and_return(double.as_null_object)
    end

    describe "allows agent to forward that email", :with_csrf_protection do
      include_context "with navigated to messages view"

      before do
        template = create(:support_email_template, title: "VAT forms", subject: "VAT Certificate", body: "VAT body")
        create(:support_email_template_attachment, template:)
        click_on "Forward with signature"
      end

      context "with a signatory template" do
        it "shows the recipients text boxes" do
          expect(page).to have_text "Enter an email subject"
          expect(page).to have_text "Add recipients to the email"
        end

        it "has subject text and value with Fw:" do
          expect(find("input.subject-input").value).to eq("Fw: #{email.subject}")
        end
      end

      context "without a valid recipient email address" do
        it "shows validation error when no recipient is added" do
          click_button "Send message"
          expect(page).to have_content("At least one recipient must be specified")
        end

        it "shows validation error when invalid recipient email is added" do
          find("input[name$='[to]']").set("invalid_email")
          find("button[data-input-field$='[to]']").click
          click_button "Send message"

          expect(page).not_to have_content("At least one recipient must be specified")
          expect(page).to have_content("The TO recipients contains an invalid email address")
        end
      end

      context "with a valid email address" do
        before do
          allow(MicrosoftGraph).to receive(:client).and_return(double(create_and_forward_new_message: message_double("forward email message"), get_file_attachments: []))
        end

        it "forward emails" do
          find("input[name$='[to]']").set(valid_email)
          find("button[data-input-field$='[to]']").click

          within(find("table[data-row-label='TO']")) do
            expect(page).to have_text valid_email
          end

          click_button "Send message"

          expect(page).to have_content("Display recipients")
          find("details", text: "Display recipients").click

          expect(page).not_to have_content("There is a problem")
          expect(page).to have_content("Forward message")
        end
      end
    end
  end
end
