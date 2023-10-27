class Tickets::MessageRepliesController < ApplicationController
  include SupportAgents

  before_action :redirect_to_portal, unless: -> { turbo_frame_request? }
  before_action :find_email
  before_action :set_back_url

  def create
    @draft = Email::Draft.new(**form_params, reply_to_email: @email)

    if @draft.valid?
      @draft.delivery_as_reply

      redirect_to message_thread_path(ticket_type: @email.ticket_type, ticket_id: @email.ticket_id, id: @email.outlook_conversation_id, back_to: params[:back_to])
    end
  end

  private

  def form_params
    params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id, :blob_attachments, file_attachments: [])
  end

  def find_email
    @email = Email.find(params[:message_id])
  end

  def set_back_url
    @back_url = back_link_param
  end

  def redirect_to_portal
    redirect_to "/cms"
  end

  def authorize_agent_scope = :access_proc_ops_portal?
end
