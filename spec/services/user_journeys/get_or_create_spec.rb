describe UserJourneys::GetOrCreate do
  describe "#call" do
    subject(:service) { described_class.new(session_id: "abc") }

    context "when a user journey with the given session_id exists" do
      it "delegates to the Get service and returns the first result" do
        user_journey = build(:user_journey)
        allow(UserJourneys::Get).to receive_message_chain(:by_session_id, :first).and_return(user_journey)
        expect(UserJourneys::Create).not_to receive(:new)

        result = service.call

        expect(result).to eq user_journey
      end
    end

    context "when a user journey with the given session_id does not exist" do
      it "delegates to the Create service" do
        user_journey = build(:user_journey)
        allow(UserJourneys::Get).to receive_message_chain(:by_session_id, :first).and_return(nil)
        allow(UserJourneys::Create).to receive_message_chain(:new, :call).and_return(user_journey)

        result = service.call

        expect(result).to eq user_journey
      end
    end
  end
end
