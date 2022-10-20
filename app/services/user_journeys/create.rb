module UserJourneys
  class Create
    def initialize(referral_campaign:, status: UserJourney.statuses[:in_progress])
      @referral_campaign = referral_campaign
      @status = status
    end

    def call
      UserJourney.create!(status: @status, referral_campaign: @referral_campaign)
    end
  end
end
