module Support
  class AgentPresenter < BasePresenter
    # @return [String]
    def full_name
      [format_name(first_name), format_name(last_name)].join(" ")
    end
  end
end
