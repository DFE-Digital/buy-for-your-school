module HasTicket
  extend ActiveSupport::Concern

  ACCEPTABLE_TICKET_TYPES = [
    "Support::Case",
    "Frameworks::Evaluation",
  ].freeze

  included do
    before_action :redirect_to_portal, unless: -> { params[:ticket_type].in?(ACCEPTABLE_TICKET_TYPES) }
    before_action :find_ticket
  end

private

  def find_ticket
    @ticket = params[:ticket_type].safe_constantize.find(params[:ticket_id])
  end
end
