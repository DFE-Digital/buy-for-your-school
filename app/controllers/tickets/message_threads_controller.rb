class Tickets::MessageThreadsController < ApplicationController
  include SupportAgents
  include HasTicket

  helper_method :back_to_url_b64

  content_security_policy do |policy|
    policy.style_src_attr :unsafe_inline
  end

  before_action :redirect_to_portal, unless: :turbo_frame_request?
  before_action :find_ticket
  before_action :set_back_url

  def index
    @threads = @ticket.message_threads.active.map { |mt| Support::MessageThreadPresenter.new(mt) }
  end

  def show
    @thread = Support::MessageThreadPresenter.new(@ticket.message_threads.find(params[:id]))
  end

  def edit
    @draft = Email::Draft.find(params[:id])
  end

  def create
    draft = Email::Draft.new(
      default_content:,
      default_subject:,
      ticket: @ticket,
      to_recipients: @ticket.default_recipients,
    ).save_draft!

    redirect_to edit_message_thread_path(ticket_id: @ticket.id, ticket_type: @ticket.class, id: draft.id)
  end

  def submit
    @draft = Email::Draft.find(params[:id])
    @draft.attributes = new_thread_params
    if @draft.valid?
      @draft.save_draft!
      @draft.deliver_as_new_message
      redirect_to message_thread_path(ticket_id: @ticket.id, ticket_type: @ticket.class, id: @draft.email.outlook_conversation_id)
    else
      render :edit
    end
  end

  def back_to_url_b64
    return Base64.encode64(edit_message_thread_path(ticket_type: @ticket.class, ticket_id: @ticket.id, id: params[:id])) if action_name == "submit"

    current_url_b64
  end

private

  def default_content = render_to_string(partial: "support/cases/messages/reply_form_template")
  def default_subject = "#{@ticket.email_prefix} - DfE Get help buying for schools"

  def new_thread_params
    params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id)
  end

  def set_back_url
    @back_url = back_link_param || message_threads_path(ticket_id: @ticket.id, ticket_type: @ticket.class)
  end

  def authorize_agent_scope = :access_proc_ops_portal?
end
