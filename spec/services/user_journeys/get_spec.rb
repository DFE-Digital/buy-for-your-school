describe UserJourneys::Get do
  subject(:service) { described_class }

  describe "#by_session_id" do
    it "delegates to UserJourney.by_session_id with the given session_id" do
      expect(UserJourney).to receive(:by_session_id).with("session_id")
      service.by_session_id(session_id: "session_id")
    end
  end

  describe "#by_framework_request_id" do
    it "delegates to UserJourney.find_by with the given framework_request_id" do
      expect(UserJourney).to receive(:find_by).with(framework_request_id: "framework_request_id")
      service.by_framework_request_id(framework_request_id: "framework_request_id")
    end
  end
end
