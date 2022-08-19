describe Support::Messages::NotifyMessagePresenter do
  include ActionView::TestCase::Behavior

  subject(:presenter) { described_class.new(message_interaction) }

  let(:message_interaction) { create(:support_interaction, :email_from_school) }

  describe "#sent_by_email" do
    it "returns the sender's email" do
      expect(presenter.sent_by_email).to eq "Email"
    end
  end

  describe "#sent_by_name" do
    it "returns the sender's name" do
      expect(presenter.sent_by_name).to eq "first_name last_name"
    end
  end

  describe "#truncated_body_for_display" do
    it "returns a truncated message body" do
      expect(presenter.truncated_body_for_display(nil)).to eq "yyy"
    end
  end

  describe "#is_read?" do
    it "returns true" do
      expect(presenter.is_read?).to eq true
    end
  end

  describe "#can_save_attachments?" do
    it "returns false" do
      expect(presenter.can_save_attachments?).to eq false
    end
  end

  describe "#can_mark_as_read?" do
    it "returns false" do
      expect(presenter.can_mark_as_read?).to eq false
    end
  end

  describe "#attachments_for_display" do
    it "returns an empty array" do
      expect(presenter.attachments_for_display).to eq []
    end
  end

  describe "#render_actions" do
    it "renders the message actions" do
      expect(view).to receive(:render).with("support/cases/message_threads/notify/actions", message: presenter)

      presenter.render_actions(view)
    end
  end

  describe "#render_details" do
    it "renders the message details" do
      expect(view).to receive(:render).with("support/cases/message_threads/notify/details", message: presenter)

      presenter.render_details(view)
    end
  end

  describe "#templated_message?" do
    context "when it is an email with a template" do
      let(:message_interaction) { create(:support_interaction, :email_from_school, additional_data: { email_template: "123" }) }

      it "returns true" do
        expect(presenter.templated_message?).to eq true
      end
    end

    context "when it is an email without a template" do
      it "returns false" do
        expect(presenter.templated_message?).to eq false
      end
    end
  end

  describe "#case" do
    it "returns a case presenter" do
      expect(presenter.case).to be_a Support::CasePresenter
    end
  end

  describe "#additional_data" do
    let(:message_interaction) { create(:support_interaction, :email_from_school, additional_data: { email_template: "f4696e59-8d89-4ac5-84ca-17293b79c337" }) }

    it "returns the email template name" do
      expect(presenter.additional_data["email_template"]).to eq "What is a framework?"
    end
  end
end
