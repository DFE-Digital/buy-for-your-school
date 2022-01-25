require_relative "case_presenter"
require_relative "agent_presenter"
require_relative "email_presenter"

module Support
  class InteractionPresenter < BasePresenter
    # @return [string]
    def created_at
      if outlook_email?
        email.sent_at.strftime(date_format)
      else
        super
      end
    end

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
      event_type.match?(/\Aemail.*/)
    end

    def outlook_email?
      event_type.in?(%w[email_from_school email_to_school]) && additional_data.key?("email_id")
    end

    def notify_email?
      event_type == "email_to_school" && !additional_data.key?("email_id")
    end

    def email
      EmailPresenter.new(super) if super
    end

  private

    # @return [String] 20 March 2021 at 12:00
    def date_format
      I18n.t("support.case.date_format")
    end

    # @example
    #  { phone_call: 1, email_from_school: 2, email_to_school: 3 }
    #
    # @return [Array] with
    def contact_events
      Support::Interaction.event_types.reject do |key, _int|
        %w[note support_request hub_notes hub_progress_notes hub_migration faf_support_request].include?(key)
      end
    end
  end
end
