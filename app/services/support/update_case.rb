module Support
  #
  # Service to update an existing Case
  #
  class UpdateCase
    attr_reader :current_case, :agent

    # @param current_case [Support::Case] existing case to be updated
    # @param agent [Support::Agent]
    def initialize(current_case, agent)
      @current_case = current_case
      @agent = agent
    end

    # @return [Support::Case]
    def call
      current_case.tap do |cc|
        cc.agent = agent
        cc.state = "open"
        cc.save!
      end
    end
  end
end
