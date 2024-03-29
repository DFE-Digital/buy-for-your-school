module Support
  class Cases::AttachmentsController < Cases::ApplicationController
    before_action :redirect_to_attachments_tab, unless: :turbo_frame_request?, only: :index
    before_action :set_filter_form, only: :index
    before_action :set_email_attachments, only: :index
    before_action :find_email_attachment, only: %i[edit update destroy]

    def index; end

    def edit
      @edit_attachment_form = Support::EditCaseAttachableForm.from(@email_attachment)
      @back_url = url_from(back_link_param) || support_case_attachments_path(@current_case, page: params[:redirect_page])
    end

    def update
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
      @email_attachment.hide

      redirect_to support_case_attachments_path(@current_case)
    end

  private

    def edit_attachment_form_params
      params.require(:edit_attachment).permit(:custom_name, :description)
    end

    def filter_form_params
      params.fetch(:filter_form, {}).permit(:sent_received)
    end

    def set_filter_form
      @filter_form = FilterAttachmentsForm.new({ sent_received: "all" }.merge(filter_form_params))
    end

    def find_email_attachment
      @email_attachment = Support::EmailAttachment.find(params[:id])
    end

    def set_email_attachments
      @email_attachments = CaseFiles::UniqueAttachmentsForCase.new(case_id: current_case.id, filter_results: @filter_form.sent_received)
        .paginate(page: params[:page], per_page: 20)
    end

    def redirect_to_attachments_tab
      redirect_to support_case_path(id: params[:case_id], anchor: "case-attachments")
    end
  end

  class FilterAttachmentsForm
    include ActiveModel::Model
    attr_accessor :sent_received
  end
end
