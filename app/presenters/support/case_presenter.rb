module Support
  class CasePresenter < BasePresenter
    # @return [String]
    def state
      super.upcase
    end

    # @return [String]
    def agent_name
      case_worker_account.name
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
  end
end
