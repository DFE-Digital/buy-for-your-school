# frozen_string_literal: true

module Support
  class AgentPresenter < BasePresenter
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # @return [false]
    def guest?
      false
    end

    # TODO: use this in auth checks
    # # @return [true]
    # def agent?
    #   true
    # end
  end
end
