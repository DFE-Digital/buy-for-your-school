class CreateTicketSearches < ActiveRecord::Migration[7.1]
  def change
    create_view :ticket_searches
  end
end
