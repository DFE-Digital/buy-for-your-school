module Support
  class InteractionPresenter < BasePresenter
    # @return [String]
    def note
      super.strip.chomp
    end

    # @return [AgentPresenter]
    def agent
      Support::AgentPresenter.new(super)
    end
  end
end
