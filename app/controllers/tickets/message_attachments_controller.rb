class Tickets::MessageAttachmentsController < ApplicationController
  include SupportAgents

  ACCEPTABLE_TICKET_TYPES = [
    "Support::Case",
    "Frameworks::Evaluation"
  ]

  before_action :redirect_to_portal, unless: -> { turbo_frame_request? && params[:ticket_type].in?(ACCEPTABLE_TICKET_TYPES) }
  before_action :find_ticket
  before_action :set_filter_form
  before_action :set_back_url
  before_action :find_attachments, only: :index
  before_action :find_attachment, only: [:edit, :update, :destroy]

  def index; end

  def edit; end

  def update
    if @attachment.update(edit_form_params)
      redirect_to message_attachments_path(ticket_type: @attachment.ticket_type, ticket_id: @attachment.ticket_id, page: params[:redirect_page])
    else
      render :edit
    end
  end

  def destroy
    @attachment.hide
    redirect_to message_attachments_path(ticket_type: @attachment.ticket_type, ticket_id: @attachment.ticket_id, page: params[:redirect_page])
  end

private

  def find_attachments
    @email_attachments = @ticket
      .unique_attachments(folder: @filter_form.sent_received)
      .paginate(page: params[:page], per_page: 20)
  end

  def set_filter_form
    @filter_form = FilterAttachmentsForm.new({ sent_received: "all" }.merge(filter_form_params))
  end

  def find_ticket
    @ticket = params[:ticket_type].safe_constantize.find(params[:ticket_id])
  end

  def filter_form_params
    params.fetch(:filter_form, {}).permit(:sent_received)
  end

  def find_attachment
    @attachment = EmailAttachment.find(params[:id])
  end

  def edit_form_params
    params.require(:email_attachment).permit(:custom_name, :description, :hidden)
  end

  def redirect_to_portal
    redirect_to "/cms"
  end

  def set_back_url
    @back_url = back_link_param
  end

  def authorize_agent_scope = :access_proc_ops_portal?

  class FilterAttachmentsForm
    include ActiveModel::Model
    attr_accessor :sent_received
  end
end
