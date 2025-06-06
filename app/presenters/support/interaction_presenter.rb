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
          email_id
          trigger_by
          format_version
        ])

        case field
        when "category_id"
          formatted_hash["category_id"] = category(value).title if value.present?
        when "detected_category_id"
          formatted_hash["detected_category_id"] = value.present? ? category(value).title : "None"
        when "email_template"
          formatted_hash["email_template"] = EmailTemplates.label_for(value)
        when "bills"
          if value.present?
            formatted_hash["bills"] = helpers.link_to("View bills in case files tab &raquo;".html_safe, routes.support_case_path(id: self.case, anchor: "case-files"), class: "govuk-link")
          end
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
      if case_categorisation_changed?
        Support::CaseCategorisationChangePresenter.new(self).body
      elsif case_source_changed?
        Support::CaseSourceChangePresenter.new(self).body
      elsif case_procurement_stage_changed?
        Support::CaseProcurementStageChangePresenter.new(self).body
      elsif case_level_changed?
        Support::CaseLevelChangePresenter.new(self).body
      elsif case_with_school_changed?
        Support::CaseWithSchoolChangePresenter.new(self).body
      elsif case_next_key_date_changed?
        Support::CaseNextKeyDateChangePresenter.new(self).body
      elsif case_transferred?
        Support::CaseTransferredPresenter.new(self).body
      elsif super
        super.strip.chomp
      end
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

    def assigned_to_agent
      return if additional_data["assigned_to_agent_id"].blank?

      AgentPresenter.new(Support::Agent.find(additional_data["assigned_to_agent_id"]))
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

    def custom_template
      return "support_request_body" if support_request?
      return "case_categorisation_changed" if case_categorisation_changed?
      return "case_source_changed" if case_source_changed?
      return "state_changes/case_assigned" if case_assigned?

      "state_changes/case_opened" if case_opened?
    end

    def event_type
      if case_categorisation_changed?
        "case_categorisation_changed.#{additional_data['type']}"
      else
        super
      end
    end

    def show_additional_data?
      if case_procurement_stage_changed?
        Support::CaseProcurementStageChangePresenter.new(self).show_additional_data?
      elsif case_level_changed?
        Support::CaseLevelChangePresenter.new(self).show_additional_data?
      elsif case_with_school_changed?
        Support::CaseWithSchoolChangePresenter.new(self).show_additional_data?
      elsif case_next_key_date_changed?
        Support::CaseNextKeyDateChangePresenter.new(self).show_additional_data?
      elsif case_transferred?
        Support::CaseTransferredPresenter.new(self).show_additional_data?
      elsif hide_additional_data?(event_type)
        false
      else
        true
      end
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
        %w[
          note
          support_request
          hub_notes
          hub_progress_notes
          hub_migration
          faf_support_request
          procurement_updated
          existing_contract_updated
          new_contract_updated
          savings_updated
          state_change
          email_merge
          create_case
          case_categorisation_changed
          case_source_changed
          case_assigned
          case_opened
          case_procurement_stage_changed
          case_next_key_date_changed
          case_transferred
          evaluator_added
          evaluator_updated
          evaluator_removed
          evaluation_due_date_added
          evaluation_due_date_updated
          documents_uploaded
          documents_deleted
          all_documents_uploaded
          email_evaluators
          documents_downloaded
          completed_documents_uploaded
          completed_documents_deleted
          all_completed_documents_uploaded
          evaluation_completed
          contract_recipient_added
          contract_recipient_updated
          contract_recipient_removed
          handover_packs_uploaded
          handover_packs_deleted
          all_handover_packs_uploaded
          share_handover_packs
          handover_packs_downloaded
          documents_uploaded_in_complete
          completed_documents_uploaded_in_complete
          handover_packs_uploaded_in_complete
          evaluation_in_completed
          all_documents_downloaded
          all_handover_packs_downloaded
        ].include?(key)
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

    def hide_additional_data?(interaction_type)
      case interaction_type
      when "evaluator_added",
           "evaluator_updated",
           "evaluator_removed",
           "evaluation_due_date_added",
           "evaluation_due_date_updated",
           "documents_uploaded",
           "documents_deleted",
           "all_documents_uploaded",
           "email_evaluators",
           "documents_downloaded",
           "completed_documents_uploaded",
           "completed_documents_deleted",
           "all_completed_documents_uploaded",
           "evaluation_completed",
           "contract_recipient_added",
           "contract_recipient_updated",
           "contract_recipient_removed",
           "handover_packs_uploaded",
           "handover_packs_deleted",
           "all_handover_packs_uploaded",
           "share_handover_packs",
           "handover_packs_downloaded",
           "documents_uploaded_in_complete",
           "completed_documents_uploaded_in_complete",
           "handover_packs_uploaded_in_complete",
           "evaluation_in_completed",
           "all_documents_downloaded",
           "all_handover_packs_downloaded"
        true
      else
        false
      end
    end
  end
end
