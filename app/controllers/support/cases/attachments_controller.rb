module Support
  class Cases::AttachmentsController < Cases::ApplicationController
    before_action :redirect_to_attachments_tab, unless: :turbo_frame_request?, only: :index

    def index
      @email_attachments = Support::EmailAttachment
        .unique_files_for_case(case_id: current_case.id)
        .paginate(page: params[:page], per_page: 20)
    end

  private

    def redirect_to_attachments_tab
      redirect_to support_case_path(id: params[:case_id], anchor: "attachments")
    end
  end
end
