module UserJourneys
  class Get
    def self.by_session_id(session_id:)
      UserJourney.by_session_id(session_id).to_a
    end

    def self.by_framework_request_id(framework_request_id:)
      UserJourney.find_by(framework_request_id:)
    end
  end
end
