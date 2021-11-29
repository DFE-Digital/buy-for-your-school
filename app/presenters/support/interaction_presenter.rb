require_relative "case_presenter"
require_relative "agent_presenter"

module Support
  class InteractionPresenter < BasePresenter
    include ActionView::Helpers
    include Rails.application.routes.url_helpers

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

    # @return [String]
    def show_body
      return link_to I18n.t(".support.interaction.link_to_email_preview"), support_case_interaction_path(id: id, case_id: case_id), target: "_blank", rel: "noopener" if email?

      body
    end

  private

    # @example
    #  { phone_call: 1, email_from_school: 2, email_to_school: 3 }
    #
    # @return [Hash] with
    def contact_events
      Interaction.event_types.reject do |key, _int|
        %w[note support_request hub_notes hub_progress_notes hub_migration].include?(key)
      end
    end

    # @return [Boolean]
    def email?
      event_type.match? /\Aemail.*/
    end
  end
end
