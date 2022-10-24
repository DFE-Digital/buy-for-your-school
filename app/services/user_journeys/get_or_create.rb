module UserJourneys
  class GetOrCreate
    def initialize(session_id:, get:, create:, referral_campaign: nil)
      @session_id = session_id
      @referral_campaign = referral_campaign
      @get = get
      @create = create
    end

    def call
      @get.new(session_id: @session_id).call.first ||
        @create.new(referral_campaign: @referral_campaign).call
    end
  end
end
