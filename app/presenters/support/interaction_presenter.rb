require_relative "case_presenter"
require_relative "agent_presenter"

module Support
  class InteractionPresenter < BasePresenter
    # @return [Hash]
    def additional_data
      super.each_with_object({}) do |(field, value), formatted_hash|
        next if field.in?(%w[
          support_request_id
          organisation_type
          organisation_urn
          organisation_id
        ])

        case field
        when "category_id"
          formatted_hash["category_id"] = category(value).title if value.present?
        when "email_template"
          formatted_hash["email_template"] = EmailTemplates.label_for(value)
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

    def no_display?
      event_type.in?(%w[procurement_updated])
    end

    def outlook_email?
      event_type.in?(%w[email_from_school email_to_school]) && additional_data.key?("email_id")
    end

  private

    # @return [String] 20 March 2021 12:00
    def date_format
      I18n.t("support.case.label.case_history.table.date_format")
    end

    # @example
    #  { phone_call: 1, email_from_school: 2, email_to_school: 3 }
    #
    # @return [Array] with
    def contact_events
      Support::Interaction.event_types.reject do |key, _int|
        %w[note support_request hub_notes hub_progress_notes hub_migration faf_support_request procurement_updated existing_contract_updated new_contract_updated savings_updated state_change email_merge create_case].include?(key)
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
