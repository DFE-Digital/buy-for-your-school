module Support
  class CasePresenter < BasePresenter
    # @return [String]
    def state
      super.upcase
    end

    # @return [String]
    def agent_name
      case_worker_account.full_name
    end

    def organisation_name
      "St.Mary"
    end

    # @return [String]
    def received_at
      interactions.first.created_at
    end

    # @return [String]
    def last_updated_at
      interactions.last.created_at
    end

    # @return [Array<InteractionPresenter>]
    def interactions
      @interactions ||= super.map { |i| Support::InteractionPresenter.new(i) }
    end

    # @return [ContactPresenter]
    def contact
      Support::ContactPresenter.new(super)
    end

    # @return [CategoryPresenter]
    def category
      Support::CategoryPresenter.new(super)
    end

    def case_worker_account
      Support::AgentPresenter.new(super)
    end
  end
end
