module Support
  class SaveAttachmentsController < ::Support::ApplicationController
    before_action :find_email
    before_action { @back_url = support_case_message_thread_path(id: @email.outlook_conversation_id, case_id: @email.case_id) }
    before_action { @subject = Support::MessageThreadPresenter.new(find_email.thread).subject }

    def new
      @save_attachments_form = SaveAttachmentsForm.from_email(@email)
    end

    def create
      @save_attachments_form = SaveAttachmentsForm.new(**save_attachments_form_params)

      if @save_attachments_form.valid? && @save_attachments_form.save_attachments
        @attachments = @save_attachments_form.selected_attachments
        respond_to do |format|
          format.turbo_stream { @current_case = Support::Case.find(@email.case_id) }
        end
      else
        render :new
      end
    end

  private

    def find_email
      @email = Support::Email.find(params[:message_id])
    end

    def save_attachments_form_params
      params.require(:save_attachments_form).permit(
        :show_file_type_warning,
        attachments_attributes: %i[
          selected
          name
          support_case_id
          support_email_attachment_id
          description
          label
        ],
      )
    end
  end
end
