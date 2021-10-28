module Support
  class InteractionPresenter < BasePresenter
    # @return [String]
    def note
      super.strip.chomp
    end

    # @return [Array<OpenStruct>]
    def contact_options
      events = Support::Interaction.event_types.keys.map do |event|
        next if %w[note support_request].include? event

        OpenStruct.new(id: event, label: event.humanize)
      end
      events.compact!
    end

    # @return [OpenStruct, AgentPresenter]
    def agent
      return OpenStruct.new(full_name: nil) if agent_id.blank?

      Support::AgentPresenter.new(super)
    end
  end
end
