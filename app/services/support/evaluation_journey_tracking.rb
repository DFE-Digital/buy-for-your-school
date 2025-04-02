require "dry-initializer"

module Support
  # Track support case activity
  #
  # @see Support::EvaluationJourneyTracking

  class EvaluationJourneyTracking
    def initialize(method, data)
      @method = method
      @data = data
    end

    def call
      send @method
    end

    # Contact-related actions
    def evaluator_added = contact_added("Evaluator")
    def evaluator_updated = contact_updated("Evaluator")
    def evaluator_removed = contact_removed("Evaluator")
    def contract_recipient_added = contact_added("Recipient")
    def contract_recipient_updated = contact_updated("Recipient")
    def contract_recipient_removed = contact_removed("Recipient")

    # Document-related actions
    def completed_documents_uploaded = documents_uploaded
    def completed_documents_deleted = documents_deleted
    def all_completed_documents_uploaded = all_documents_uploaded
    def handover_packs_uploaded = documents_uploaded
    def handover_packs_deleted = documents_deleted
    def all_handover_packs_uploaded = all_documents_uploaded
    def handover_packs_downloaded = documents_downloaded
    def completed_documents_uploaded_in_complete = documents_uploaded_in_complete
    def handover_packs_uploaded_in_complete = documents_uploaded_in_complete

    # Evaluation-related actions
    def evaluation_completed = evaluation_process("complete")
    def evaluation_in_completed = evaluation_process("incomplete")

    # Email-related actions
    def email_evaluators = email_user
    def share_handover_packs = email_user

    def evaluation_due_date_updated
      if @data.saved_changes["evaluation_due_date"].first.present?
        method = :evaluation_due_date_updated
        old_date = @data.saved_changes["evaluation_due_date"].first
        new_date = @data.saved_changes["evaluation_due_date"].last
        body = "Due date changed from #{old_date} to #{new_date} by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = { from: old_date, to: new_date }
      else
        method = :evaluation_due_date_added
        body = "Due date set to #{@data.evaluation_due_date} by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = { due_date: @data.evaluation_due_date }
      end

      log_action(method, @data.id, body, additional_data)
    end

    def documents_uploaded
      body = "#{@data[:file_name]} added by #{@data[:name]}"
      additional_data = { event: "document_upload", file_name: @data[:file_name], document_id: @data[:document_id], user_id: @data[:user_id] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def documents_deleted
      body = "#{@data[:file_name]} deleted by #{@data[:name]}"
      additional_data = { event: "document_delete", file_name: @data[:file_name], document_id: @data[:document_id], user_id: @data[:user_id] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def all_documents_uploaded
      body = "Upload documents marked complete by #{@data[:name]}"
      additional_data = { event: "all_documents_uploaded", uploaded_all: "Yes", user_id: @data[:user_id] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def documents_uploaded_in_complete
      body = "Upload documents marked incomplete by #{@data[:name]}"
      additional_data = { event: "documents_uploaded_in_complete", uploaded_all: "No", user_id: @data[:user_id] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def documents_downloaded
      body = "#{@data[:file_name]} downloaded by #{@data[:name]}"
      additional_data = { event: @method, file_name: @data[:file_name], document_id: @data[:document_id], user_id: @data[:user_id] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def all_documents_downloaded
      body = "All documents downloaded by #{@data[:name]}"
      additional_data = { event: @method, user_id: @data[:user_id] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def evaluation_process(status)
      body = "Evaluation marked #{status} by #{Current.agent.first_name} #{Current.agent.last_name}"
      additional_data = { event: @method, agent_id: Current.agent.id }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

    def contact_added(type)
      body = "#{type} #{@data.name} added by #{Current.agent.first_name} #{Current.agent.last_name}"
      additional_data = {
        event: "new",
        contact_id: @data.id,
        first_name: @data.first_name,
        last_name: @data.last_name,
        email: @data.email,
      }
      log_action(@method, @data.support_case_id, body, additional_data)
    end

    def contact_updated(type)
      from_first_name = @data.saved_changes["first_name"]&.first || @data.first_name
      to_first_name = @data.saved_changes["first_name"]&.last || @data.first_name

      from_last_name = @data.saved_changes["last_name"]&.first || @data.last_name
      to_last_name = @data.saved_changes["last_name"]&.last || @data.last_name

      from_email = @data.saved_changes["email"]&.first || @data.email
      to_email = @data.saved_changes["email"]&.last || @data.email

      old_name = [from_first_name, from_last_name].compact.join(" ")
      new_name = [to_first_name, to_last_name].compact.join(" ")

      if @data.saved_change_to_first_name? || @data.saved_change_to_last_name?
        body = "#{type} #{old_name} changed to #{new_name} by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = {
          event: "modify",
          contact_id: @data.id,
          from: { first_name: from_first_name, last_name: from_last_name },
          to: { first_name: to_first_name, last_name: to_last_name },
        }
        log_action(@method, @data.support_case_id, body, additional_data)
      end

      if @data.saved_change_to_email?
        body = "#{type} email for #{new_name} updated by #{Current.agent.first_name} #{Current.agent.last_name}"
        additional_data = {
          event: "modify",
          contact_id: @data.id,
          from: { email: from_email },
          to: { email: to_email },
        }
        log_action(@method, @data.support_case_id, body, additional_data)
      end
    end

    def contact_removed(type)
      body = "#{type} #{@data.name} removed by #{Current.agent.first_name} #{Current.agent.last_name}"
      additional_data = {
        event: "remove",
        first_name: @data.first_name,
        last_name: @data.last_name,
        email: @data.email,
        contact_id: @data.id,
      }
      log_action(@method, @data.support_case_id, body, additional_data)
    end

    def email_user
      body = "Email sent to #{@data[:to_recipients]}"
      additional_data = { support_email_id: @data[:email_id], recipients: @data[:to_recipients] }
      log_action(@method, @data[:support_case_id], body, additional_data)
    end

  private

    def log_action(method, case_id, body, additional_data)
      Support::Interaction.create!(
        body:,
        agent: Current.agent,
        case_id:,
        event_type: method,
        additional_data:,
        show_case_history: false,
      )
    end
  end
end
