module Support
  class Cases::FilesController < Cases::ApplicationController
    before_action :redirect_to_files_tab, unless: :turbo_frame_request?, only: :index

    def index
      @case_files = current_case.case_attachments
        .paginate(page: params[:page], per_page: 20)
    end

    def new
      @file_uploader = current_case.file_uploader
    end

    def create
      @file_uploader = current_case.file_uploader(file_uploader_params)
      if @file_uploader.valid?
        @file_uploader.save!
        redirect_to support_case_files_path
      else
        render :new
      end
    end

    def edit
      @case_file = Support::CaseAttachment.find(params[:id])
      @edit_file_form = Support::EditCaseAttachableForm.from(@case_file)
    end

    def update
      @case_file = Support::CaseAttachment.find(params[:id])
      @edit_file_form = Support::EditCaseAttachableForm.new(
        update_action: CaseFiles::RenameFile.new(@case_file),
        **edit_file_form_params,
      )

      if @edit_file_form.valid?
        @edit_file_form.update!

        redirect_to support_case_files_path(@current_case, page: params[:redirect_page])
      else
        render :edit
      end
    end

    def destroy
      @case_file = Support::CaseAttachment.find(params[:id])
      @case_file.destroy!

      redirect_to_files_tab
    end

  private

    def edit_file_form_params
      params.require(:edit_file).permit(:custom_name, :description)
    end

    def file_uploader_params
      params.fetch(:file_uploader, {}).permit(files: [])
    end

    def redirect_to_files_tab
      redirect_to support_case_path(id: params[:case_id], anchor: "case-files")
    end
  end
end
