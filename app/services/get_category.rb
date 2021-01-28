class GetCategory
  attr_accessor :category_entry_id
  def initialize(category_entry_id:)
    self.category_entry_id = category_entry_id
  end

  def call
    begin
      GetEntry.new(entry_id: category_entry_id).call
    rescue GetEntry::EntryNotFound
      send_rollbar_error(message: "A Contentful category entry was not found", entry_id: category_entry_id)
      raise
    end
  end

  private

  def send_rollbar_error(message:, entry_id:)
    Rollbar.error(
      message,
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id
    )
  end
end
