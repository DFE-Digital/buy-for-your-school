class Tickets::MessageThreadsController < ApplicationController
  include SupportAgents
  include HasTicket

  content_security_policy do |policy|
    policy.style_src_attr :unsafe_inline
  end

  before_action :redirect_to_portal, unless: :turbo_frame_request?
  before_action :find_ticket
  before_action :set_back_url

  def index
    @threads = @ticket.message_threads.map { |mt| Support::MessageThreadPresenter.new(mt) }
  end

  def show
    @thread = Support::MessageThreadPresenter.new(@ticket.message_threads.find(params[:id]))

    @reply_form = Email::Draft.new(
      ticket: @ticket,
      default_content:,
    )
  end

  def new
    @draft = Email::Draft.new(
      ticket: @ticket,
      to_recipients: @ticket.default_recipients,
      default_content:,
      default_subject:,
    )
  end

  def create
    @draft = Email::Draft.new(ticket: @ticket, **new_thread_params)

    if @draft.valid?(context: :new_message)
      email = @draft.deliver_as_new_message

      redirect_to message_thread_path(
        id: email.outlook_conversation_id,
        ticket_id: @ticket.id,
        ticket_type: @ticket.class,
        back_to: Base64.encode64(message_threads_path(ticket_id: @ticket.id, ticket_type: @ticket.class)),
      )
    else
      @body = form_params[:html_content]
      @subject = form_params[:subject]
      @to_recipients = form_params[:to_recipients]
      @cc_recipients = form_params[:cc_recipients]
      @bcc_recipients = form_params[:bcc_recipients]
      @show_attachment_warning = Array(form_params[:attachments]).any?

      render :edit
    end
  end

private

  def default_content = render_to_string(partial: "support/cases/messages/reply_form_template")
  def default_subject = "#{@ticket.email_prefix} - DfE Get help buying for schools"

  def new_thread_params
    params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id, :blob_attachments, file_attachments: [])
  end

  def set_back_url
    @back_url = back_link_param
  end

  def authorize_agent_scope = :access_proc_ops_portal?
end
