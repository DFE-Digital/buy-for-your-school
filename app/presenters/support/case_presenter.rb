# frozen_string_literal: true

require_relative "interaction_presenter"
require_relative "contact_presenter"
require_relative "category_presenter"
require_relative "agent_presenter"

module Support
  class CasePresenter < BasePresenter
    # @return [String]
    def state
      super.upcase
    end

    # @return [String]
    def agent_name
      agent&.full_name || "UNASSIGNED"
    end

    def organisation_name
      "St.Mary"
    end

    # @return [String]
    def request_text
      super.strip.chomp
    end

    # @return [String] 30 January 2000 at 12:00
    def received_at
      created_at
    end

    # @return [String]
    def last_updated_at
      interactions.present? ? interactions&.last&.created_at : created_at
    end

    # return interactions excluding the event_type of support_request
    # @return [Array<InteractionPresenter>]
    def interactions
      @interactions ||= super.not_support_request.map { |i| InteractionPresenter.new(i) }
    end

    # return single interaction of support_request event_type
    # @return [nil, InteractionPresenter]
    def support_request
      InteractionPresenter.new(super)
    end

    # @return [nil, AgentPresenter]
    def agent
      AgentPresenter.new(super) if super
    end

    # @return [ContactPresenter]
    def contact
      ContactPresenter.new(super)
    end

    # @return [CategoryPresenter]
    def category
      CategoryPresenter.new(super)
    end
  end
end
