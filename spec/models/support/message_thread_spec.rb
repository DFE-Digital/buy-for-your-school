RSpec.describe Support::MessageThread do
  describe "#last_received_reply" do
    before do
      ticket = create(:support_case)
      create(:support_email, :inbox, subject: "Email 1", ticket:, sent_at: Time.zone.parse("01/01/2022 10:32"))
      create(:support_email, :inbox, subject: "Email 2", ticket:, sent_at: Time.zone.parse("01/01/2022 10:35"))
    end

    it "returns the last received reply" do
      thread = described_class.find_by(conversation_id: "MyString")
      expect(thread.last_received_reply.subject).to eq "Email 2"
    end
  end
end
