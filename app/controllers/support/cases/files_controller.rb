module Support
  class Cases::FilesController < Cases::ApplicationController
    before_action :redirect_to_files_tab, unless: :turbo_frame_request?, only: :index

    def index
      @case_files = (current_case.energy_bills + current_case.case_attachments)
        .paginate(page: params[:page], per_page: 20)
    end

    def destroy
      @case_file = Support::CaseAttachment.find(params[:id])
      @case_file.destroy!

      redirect_to_files_tab
    end

  private

    def redirect_to_files_tab
      redirect_to support_case_path(id: params[:case_id], anchor: "case-files")
    end
  end
end
