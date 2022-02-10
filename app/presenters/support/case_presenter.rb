# frozen_string_literal: true

require_relative "interaction_presenter"
require_relative "category_presenter"
require_relative "agent_presenter"
require_relative "organisation_presenter"
require_relative "procurement_presenter"
require_relative "contract_presenter"

module Support
  class CasePresenter < BasePresenter
    include ActionView::Helpers::NumberHelper

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

    # @return [String] 30 January 2000 at 12:00
    def received_at
      created_at
    end

    # @return [String] 30 January 2000 at 12:00
    def last_updated_at
      # method to compare updated_at for case and updated_at for interaction (if exists) and select most recent
      interactions.none? ? updated_at : interactions.last.created_at
    end

    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # return interactions excluding the event_type of support_request
    # @return [Array<InteractionPresenter>]
    def interactions
      @interactions ||= super.not_support_request.map { |i| InteractionPresenter.new(i) }
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

    # @return [String]
    def org_name
      if organisation.present?
        organisation.name
      elsif email.present?
        email
      else
        "n/a"
      end
    end

    # @return [String]
    def org_urn
      return "n/a" if organisation.blank?

      organisation.urn
    end

    # @return [OrganisationPresenter]
    def organisation
      OrganisationPresenter.new(super) if super
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

  private

    # @return [String] 20 March 2021 at 12:00
    def date_format
      I18n.t("support.case.date_format")
    end
  end
end
