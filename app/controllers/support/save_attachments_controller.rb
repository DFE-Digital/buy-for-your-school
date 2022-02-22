module Support
  class SaveAttachmentsController < ::Support::ApplicationController
    before_action :find_email
    before_action { @back_url = support_email_path(@email) }

    def new
      @save_attachments_form = SaveAttachmentsForm.from_email(@email)
    end

    def create
      @save_attachments_form = SaveAttachmentsForm.new(**save_attachments_form_params)

      if @save_attachments_form.valid?
        @save_attachments_form.save_attachments
        @attachments = @save_attachments_form.selected_attachments
      else
        render :new
      end
    end

  private

    def find_email
      @email = Support::Email.find(params[:email_id])
    end

    def save_attachments_form_params
      params.require(:save_attachments_form).permit(attachments_attributes: %i[
        selected
        name
        support_case_id
        support_email_attachment_id
        description
        label
      ])
    end
  end
end
