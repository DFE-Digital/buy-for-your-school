module UserJourneys
  class Get
    def initialize(session_id:)
      @session_id = session_id
    end

    def call
      UserJourney.by_session_id(@session_id).to_a
    end
  end
end
