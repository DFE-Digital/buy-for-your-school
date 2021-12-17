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

    # @return [Boolean]
    def email?
      event_type.match? /\Aemail.*/
    end

  private

    # @return [String] 20 March 2021 at 12:00
    def date_format
      I18n.t("support.case.date_format")
    end

    # @example
    #  { phone_call: 1, email_from_school: 2, email_to_school: 3 }
    #
    # @return [Hash] with
    def contact_events
      Interaction.event_types.reject do |key, _int|
        %w[note support_request hub_notes hub_progress_notes hub_migration].include?(key)
      end
    end
  end
end
