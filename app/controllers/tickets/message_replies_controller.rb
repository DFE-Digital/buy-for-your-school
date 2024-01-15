class Tickets::MessageRepliesController < ApplicationController
  include SupportAgents

  before_action :redirect_to_portal, unless: :turbo_frame_request?
  before_action :find_email

  helper_method :back_to_url_b64

  def edit
    @reply_form = Email::Draft.find(params[:id])
    @last_received_reply = Support::Messages::OutlookMessagePresenter.new(@email)
  end

  def create
    @draft = Email::Draft.new(
      default_content:,
      template_id: params[:template_id],
      ticket: @email.ticket,
      reply_to_email: @email,
    ).save_draft!

    redirect_to edit_message_reply_path(message_id: @email.id, id: @draft.id)
  end

  def submit
    @reply_form = Email::Draft.find(params[:id])
    @reply_form.reply_to_email = @email
    @reply_form.attributes = form_params
    if @reply_form.valid?
      @reply_form.save_draft!
      @reply_form.delivery_as_reply

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.redirect(message_thread_path(ticket_type: @email.ticket_type, ticket_id: @email.ticket_id, id: @email.outlook_conversation_id, back_to: params[:back_to]), "messages-frame")
        end
        format.html { redirect_to message_thread_path(ticket_type: @email.ticket_type, ticket_id: @email.ticket_id, id: @email.outlook_conversation_id, back_to: params[:back_to]) }
      end
    else
      @last_received_reply = Support::Messages::OutlookMessagePresenter.new(@email)
      render :edit
    end
  end

  def back_to_url_b64
    return Base64.encode64(edit_message_reply_path(message_id: params[:message_id], id: params[:id])) if action_name == "submit"

    current_url_b64
  end

private

  def default_content = render_to_string(partial: "support/cases/messages/reply_form_template")

  def form_params
    params.require(:"message_reply_form_#{params[:unique_id]}").permit(:html_content, :subject, :to_recipients, :cc_recipients, :bcc_recipients, :template_id)
  end

  def find_email
    @email = Email.find(params[:message_id])
  end

  def authorize_agent_scope = :access_proc_ops_portal?
end
