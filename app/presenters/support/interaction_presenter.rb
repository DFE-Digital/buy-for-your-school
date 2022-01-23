require_relative "case_presenter"
require_relative "agent_presenter"
require_relative "email_presenter"

module Support
  class InteractionPresenter < BasePresenter
    # @return [Hash]
    def additional_data
      super.each_with_object({}) do |(field, value), formatted_hash|
        next if field.in?(%w[support_request_id])

        case field
        when "organisation_id"
          formatted_hash["organisation_id"] = organisation(value).name
        when "category_id"
          formatted_hash["category_id"] = category(value).title
        else
          formatted_hash[field] = value
        end
      end
    end

    # @return [string]
    def created_at
      if outlook_email?
        email.sent_at.strftime(date_format)
      else
        super
      end
    end

    # @return [String]
    def body
      super.strip.chomp if super
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
      Interaction.event_types.reject do |key, _int|
        %w[note support_request hub_notes hub_progress_notes hub_migration].include?(key)
      end
    end

    # @return [Support::OrganisationPresenter]
    def organisation(organisation_id)
      @organisation ||= OrganisationPresenter.new(Organisation.find(organisation_id))
    end

    # @return [Support::CategoryPresenter]
    def category(category_id)
      @category ||= CategoryPresenter.new(Category.find(category_id))
    end
  end
end
