module Support
  class CasePresenter < BasePresenter
    # @return [String]
    def state
      super.upcase
    end

    # @return [String]
    def agent_name
      return agent.full_name if agent.present?

      ""
    end

    def organisation_name
      "St.Mary"
    end

    # @return [String]
    def received_at
      enquiry.created_at
    end

    # @return [String]
    def last_updated_at
      interactions&.last&.created_at || enquiry.created_at
    end

    # @return [Array<InteractionPresenter>]
    def interactions
      @interactions ||= super.map { |i| Support::InteractionPresenter.new(i) }
    end

    # @return [AgentPresenter]
    def agent
      Support::AgentPresenter.new(super)
    end

    # @return [ContactPresenter]
    def contact
      Support::ContactPresenter.new(super)
    end

    # @return [CategoryPresenter]
    def category
      Support::CategoryPresenter.new(super)
    end

    # @return [EnquiryPresenter]
    def enquiry
      Support::EnquiryPresenter.new(super)
    end
  end
end
