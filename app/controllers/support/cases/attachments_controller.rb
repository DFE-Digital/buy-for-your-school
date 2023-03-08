module Support
  class Cases::AttachmentsController < Cases::ApplicationController
    before_action :redirect_to_attachments_tab, unless: :turbo_frame_request?, only: :index
    before_action :set_email_attachments, only: :index

    def destroy
      CaseFiles::HideAttachment.new.call(attachment_id: params[:id])

      respond_to do |format|
        format.turbo_stream do
          @show_tab = true
          set_email_attachments
        end
        format.html { redirect_to_attachments_tab }
      end
    end

  private

    def set_email_attachments
      @email_attachments = CaseFiles::UniqueAttachmentsForCase.new(case_id: current_case.id)
        .paginate(page: params[:page], per_page: 20)
    end

    def redirect_to_attachments_tab
      redirect_to support_case_path(id: params[:case_id], anchor: "case-attachments")
    end
  end
end
