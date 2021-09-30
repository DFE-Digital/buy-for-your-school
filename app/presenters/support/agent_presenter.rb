module Support
  class AgentPresenter < BasePresenter
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
