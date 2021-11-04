require_relative "case_presenter"
require_relative "agent_presenter"

module Support
  class InteractionPresenter < BasePresenter
    # @return [String]
    def note
      super.strip.chomp
    end

    # @return [Array<OpenStruct>]
    def contact_options
      contact_events.map do |event, _|
        OpenStruct.new(id: event, label: event.humanize)
      end
    end

    # @return [AgentPresenter]
    def agent
      AgentPresenter.new(super) if super
    end

    # @return [CasePresenter]
    def case
      CasePresenter.new(super)
    end

  private

    # @example
    #  { phone_call: 1, email_from_school: 2, email_to_school: 3 }
    #
    # @return [Hash] with
    def contact_events
      Interaction.event_types.reject do |key, _int|
        %w[note support_request].include?(key)
      end
    end
  end
end
