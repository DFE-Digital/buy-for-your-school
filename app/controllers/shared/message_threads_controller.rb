class Shared::MessageThreadsController < ApplicationController
  include SupportAgents

  ACCEPTABLE_TICKET_TYPES = [
    "Support::Case",
    "Frameworks::Evaluation"
  ]

  content_security_policy do |policy|
    policy.style_src_attr :unsafe_inline
  end

  before_action :redirect_to_portal, unless: -> { turbo_frame_request? && params[:ticket_type].in?(ACCEPTABLE_TICKET_TYPES) }
  before_action :find_ticket
  before_action :set_back_url

  def index
    @threads = @ticket.message_threads.map {|mt| Support::MessageThreadPresenter.new(mt) }
  end

  def show
    @thread = Support::MessageThreadPresenter.new(@ticket.message_threads.find(params[:id]))

    @reply_form = Email::Draft.new(
      ticket: @ticket,
      default_content:
    )
  end

  private

  def default_content = render_to_string(partial: "support/cases/messages/reply_form_template")

  def find_ticket
    @ticket = params[:ticket_type].safe_constantize.find(params[:ticket_id])
  end

  def set_back_url
    @back_url = params[:back_to]
  end

  def redirect_to_portal
    redirect_to "/cms"
  end

  def authorize_agent_scope = :access_proc_ops_portal?
end
