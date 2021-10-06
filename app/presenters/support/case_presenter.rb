# frozen_string_literal: true

require_relative "interaction_presenter"
require_relative "contact_presenter"
require_relative "category_presenter"

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
    def received_at
      enquiry.created_at
    end

    # @return [String]
    def last_updated_at
      interactions&.last&.created_at || enquiry.created_at
    end

    # @return [Array<InteractionPresenter>]
    def interactions
      @interactions ||= super.map { |i| InteractionPresenter.new(i) }
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

    # @return [EnquiryPresenter]
    def enquiry
      Support::EnquiryPresenter.new(super)
    end
  end
end
