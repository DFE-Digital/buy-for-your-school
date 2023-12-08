class Tickets::AttachEmailAttachmentsController < ApplicationController
  include SupportAgents

  content_security_policy do |policy|
    policy.style_src_attr :unsafe_inline
  end

  before_action :turbo_frame
  before_action :redirect_to_portal, unless: :turbo_frame_request?
  before_action :set_back_url
  before_action :set_filter_form
  before_action :find_email
  before_action :find_attachments, only: :index

  def index
    @blob_attachment_picker = @email.blob_attachment_picker(form_params)
  end

  def create
    @blob_attachment_picker = @email.blob_attachment_picker(form_params)
    if @blob_attachment_picker.valid?
      @blob_attachment_picker.save!
      redirect_to @back_url
    else
      render :index
    end
  end

private

  def find_email
    @email = Email.find(params[:message_id])
  end

  def find_attachments
    @email_attachments = @email.ticket
      .unique_attachments(folder: @filter_form.sent_received)
      .paginate(page: params[:page], per_page: 20)
  end

  def set_filter_form
    @filter_form = FilterAttachmentsForm.new({ sent_received: "all" }.merge(filter_params))
  end

  def filter_params
    params.fetch(:blob_attachment_picker, {}).permit(:sent_received)
  end

  def form_params
    params.fetch(:blob_attachment_picker, {}).permit(attachments: [])
  end

  def set_back_url
    @back_url = back_link_param
  end

  def turbo_frame
    @turbo_frame = params[:turbo_frame] || "messages-frame"
  end

  def authorize_agent_scope = :access_proc_ops_portal?

  class FilterAttachmentsForm
    include ActiveModel::Model
    attr_accessor :sent_received
  end
end
