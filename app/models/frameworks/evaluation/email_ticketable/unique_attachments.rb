class Frameworks::Evaluation::EmailTicketable::UniqueAttachments
  def initialize(ticket:, folder: "all")
    @ticket = ticket
    @folder = folder
  end

  delegate :paginate, to: :query

  def each(&block)
    return to_enum(:each) unless block_given?

    query.each(&block)
  end

private

  def filter_to_apply
    return {} unless @folder.in?(%w[sent received])

    { email: { folder: @folder == "received" ? :inbox : :sent_items } }
  end

  def query
    EmailAttachment
      .for_ticket(ticket_id: @ticket.id)
      .where(hidden: false, **filter_to_apply)
      .unique_files
      .reorder(is_inline: :asc, created_at: :desc)
  end
end
