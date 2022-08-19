describe Support::MessageThreadPresenter do
  subject(:presenter) { described_class.new(thread) }

  before do
    kase = create(:support_case)
    create(:support_email, recipients: [{ name: "recipient 1", address: "recipient1@email.com" }], sent_at: Time.zone.parse("01/01/2022 10:30"), case: kase)
    create(:support_email, recipients: [{ name: "recipient1@email.com", address: "recipient1@email.com" }], sent_at: Time.zone.parse("01/01/2022 10:32"), case: kase)
    create(:support_email, recipients: [{ name: "school@email.co.uk", address: "school@email.co.uk" }], sent_at: Time.zone.parse("01/01/2022 10:34"), case: kase)
    create(:support_email, recipients: [{ name: "sharedMailbox", address: "sharedMailbox@email.com" }], sent_at: Time.zone.parse("01/01/2022 10:35"), case: kase)
  end

  let(:thread) { Support::MessageThread.find_by(conversation_id: "MyString") }

  describe "#recipients" do
    around do |example|
      ClimateControl.modify(MS_GRAPH_SHARED_MAILBOX_NAME: "sharedMailbox") do
        example.run
      end
    end

    it "lists all the recipients except for the shared mailbox" do
      expect(presenter.recipients).to eq "recipient 1, School Contact"
    end
  end

  describe "#last_updated" do
    it "returns a formatted date" do
      expect(presenter.last_updated).to eq "01 January 2022 10:35"
    end
  end

  describe "#messages" do
    it "returns messages wrapped in presenters" do
      expect(presenter.messages).to all(be_a Support::Messages::OutlookMessagePresenter)
    end
  end

  describe "#subject" do
    it "returns the subject of the first message" do
      expect(presenter.subject).to eq "Support Case #001"
    end
  end
end
