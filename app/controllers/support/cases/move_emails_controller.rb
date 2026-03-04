module Support
  module Cases
    class MoveEmailsController < Cases::ApplicationController
      before_action :back_url, only: %i[index confirm]

      def index
        @case_email_mover = current_case.email_mover
      end

      def confirm
        @case_email_mover = current_case.email_mover(form_params)
        if @case_email_mover.valid?
          @back_url = support_case_move_emails_path
          @destination = @case_email_mover.destination
          render :confirm
        else
          render :index
        end
      end

      def create
        @case_email_mover = current_case.email_mover(form_params)
        if @case_email_mover.valid?
          uniq_emails = current_case.emails.distinct(:outlook_conversation_id).to_a
          @case_email_mover.save!
          @destination = @case_email_mover.destination
          update_emails_subject(uniq_emails:, from_case: current_case, to_case: @destination)

          render :success
        else
          back_url
          render :index
        end
      end

    private

      def back_url
        @back_url = url_from(back_link_param) || support_case_path(current_case)
      end

      def form_params
        params.fetch(:case_email_mover, {}).permit(:destination_id, :destination_type, :destination_ref)
      end

      def current_case
        @current_case ||= CasePresenter.new(super)
      end

      def update_emails_subject(uniq_emails:, from_case:, to_case:)
        if uniq_emails.present?
          Support::UpdateEmailSubjectJob.perform_later(email_ids: uniq_emails.pluck(:id), to_case_id: to_case.id, from_case_id: from_case.id)
        else
          Rails.logger.info("Not updating email subjects as more than 1 unique emails or no emails found for case ##{from_case.ref}")
        end
      end
    end
  end
end
