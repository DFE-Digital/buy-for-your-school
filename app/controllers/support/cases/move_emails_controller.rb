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
          @case_email_mover.save!
          @destination = @case_email_mover.destination
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
    end
  end
end
