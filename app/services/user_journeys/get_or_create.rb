module UserJourneys
  class GetOrCreate
    def initialize(session_id:, get: Get, create: Create, referral_campaign: nil)
      @session_id = session_id
      @referral_campaign = referral_campaign
      @get = get
      @create = create
    end

    def call
      @get.by_session_id(session_id: @session_id).first ||
        @create.new(referral_campaign: @referral_campaign).call
    end
  end
end
