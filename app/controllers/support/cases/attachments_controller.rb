module Support
  class Cases::AttachmentsController < Cases::ApplicationController
    before_action :redirect_to_attachments_tab, unless: :turbo_frame_request?, only: :index
    before_action :set_email_attachments, only: :index

    def index; end

    def edit
      @email_attachment = Support::EmailAttachment.find(params[:id])
      @edit_attachment_form = Support::EditCaseAttachableForm.from(@email_attachment)
    end

    def update
      @email_attachment = Support::EmailAttachment.find(params[:id])
      @edit_attachment_form = Support::EditCaseAttachableForm.new(
        update_action: CaseFiles::RenameFile.new(@email_attachment),
        **edit_attachment_form_params,
      )

      if @edit_attachment_form.valid?
        @edit_attachment_form.update!

        redirect_to support_case_attachments_path(@current_case, page: params[:redirect_page])
      else
        render :edit
      end
    end

    def destroy
      CaseFiles::HideAttachment.new.call(attachment_id: params[:id])

      redirect_to support_case_attachments_path(@current_case)
    end

  private

    def edit_attachment_form_params
      params.require(:edit_attachment).permit(:custom_name, :description)
    end

    def set_email_attachments
      @email_attachments = CaseFiles::UniqueAttachmentsForCase.new(case_id: current_case.id)
        .paginate(page: params[:page], per_page: 20)
    end

    def redirect_to_attachments_tab
      redirect_to support_case_path(id: params[:case_id], anchor: "case-attachments")
    end
  end
end
