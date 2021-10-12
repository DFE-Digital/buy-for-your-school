module Support
  class InteractionPresenter < BasePresenter
    # @return [String]
    def note
      super.strip.chomp
    end

    # @return [Array<OpenStruct>]
    def contact_options
      events = Support::Interaction.event_types.keys.map do |event|
        next if event == "note"

        OpenStruct.new(id: event, label: event.humanize)
      end
      events.compact!
    end

    # @return [AgentPresenter]
    def agent
      Support::AgentPresenter.new(super)
    end
  end
end
