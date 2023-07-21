# frozen_string_literal: true

require_relative "interaction_presenter"
require_relative "category_presenter"
require_relative "agent_presenter"
require_relative "organisation_presenter"
require_relative "procurement_presenter"
require_relative "contract_presenter"
require_relative "establishment_group_presenter"
require_relative "concerns/has_organisation"

module Support
  class CasePresenter < BasePresenter
    include ActionView::Helpers::NumberHelper
    include Support::Concerns::HasOrganisation
    include Support::Concerns::HasCreator

    # @return [String]
    def state
      super.upcase
    end

    # @return [String]
    def agent_name
      agent&.full_name || "UNASSIGNED"
    end

    # @return [String]
    def request_text
      String(super).strip.chomp
    end

    def initial_request_text
      return "-" unless super

      String(super).strip.chomp
    end

    # @return [String] 30 January 2000 at 12:00
    def received_at
      created_at
    end

    # @return [String] 30 January 2000 at 12:00
    def last_updated_at
      # method to compare updated_at for case and updated_at for interaction (if exists) and select most recent
      interactions.none? ? updated_at : interactions.first.created_at
    end

    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # return interactions excluding the event_type of support_request
    # @return [Array<InteractionPresenter>]
    def interactions
      @interactions ||= super.not_support_request
                             .order("created_at ASC")
                             .map { |i| InteractionPresenter.new(i) }
    end

    # return case history interactions
    # @return [Array<InteractionPresenter>]
    def case_history_interactions
      @case_history_interactions ||= __getobj__.interactions.case_history
                                               .order("created_at ASC")
                                               .map { |i| InteractionPresenter.new(i) }
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

    # @return [CategoryPresenter]
    def category
      CategoryPresenter.new(super)
    end

    def organisation_name
      super || email || "n/a"
    end

    def organisation_urn
      super || "n/a"
    end

    def savings_status
      return "-" unless super

      I18n.t("support.case_savings.edit.savings_status.states.#{super}")
    end

    def savings_estimate_method
      return "-" unless super

      I18n.t("support.case_savings.edit.savings_estimate_method.states.#{super}")
    end

    def savings_actual_method
      return "-" unless super

      I18n.t("support.case_savings.edit.savings_actual_method.states.#{super}")
    end

    def savings_estimate
      return "-" unless super

      number_to_currency(super, unit: "£", precision: 2)
    end

    def savings_actual
      return "-" unless super

      number_to_currency(super, unit: "£", precision: 2)
    end

    # @return [ProcurementPresenter, nil]
    def procurement
      ProcurementPresenter.new(super) if super
    end

    def existing_contract
      ContractPresenter.new(super) if super
    end

    def new_contract
      ContractPresenter.new(super) if super
    end

    # @return [Time]
    def last_updated_at_date
      Time.zone.parse(last_updated_at)
    end

    # true if the case source is `nw_hub`, `sw_hub` or nil
    #
    # @return [Boolean]
    def created_manually?
      ["nw_hub", "sw_hub", nil].any? { |t| t == source }
    end

    # return [String]
    def procurement_amount
      return "-" unless super

      number_to_currency(super, unit: "£", precision: 2)
    end

    # return [String]
    def special_requirements
      super || "-"
    end

    def has_special_requirements?
      special_requirements != "-"
    end

    # @return [Array<MessageThreadPresenter>]
    def message_threads
      # there are occassional emails with no conversation_id?
      super.includes([:messages]).filter { |t| t.id.present? }.map { |thread| MessageThreadPresenter.new(thread) }
    end

    # @return [Array<Messages::NotifyMessagePresenter>]
    def templated_messages
      __getobj__.interactions.templated_messages.map { |message| Messages::NotifyMessagePresenter.new(message) }
    end

    # @return [Array<Messages::NotifyMessagePresenter>]
    def logged_contacts
      __getobj__.interactions.logged_contacts.map { |contact| Messages::NotifyMessagePresenter.new(contact) }
    end

    # @return [String]
    def templated_messages_last_updated
      templated_messages.first.__getobj__.created_at.strftime("%d %B %Y %H:%M")
    end

    # @return [String]
    def logged_contacts_last_updated
      logged_contacts.first.__getobj__.created_at.strftime("%d %B %Y %H:%M")
    end

    delegate :body, to: :latest_note, prefix: true

    def latest_note_date
      latest_note.created_at.strftime("%d %b %y")
    end

    def latest_note_author
      latest_note.agent
    end

    def value
      return I18n.t("support.case.label.value.unspecified") unless super

      number_to_currency(super, unit: "£", precision: 2)
    end

    def creator_full_name
      return "Not set" unless creator

      creator.full_name
    end

    def procurement_stage
      Support::ProcurementStagePresenter.new(super) if super
    end

  private

    # @return [String] 20 March 2021 at 12:00
    def date_format
      I18n.t("support.case.date_format")
    end
  end
end
