class GetEntriesInCategory
  class RepeatEntryDetected < StandardError; end

  attr_accessor :category_entry_id
  def initialize(category_entry_id:)
    self.category_entry_id = category_entry_id
  end

  def call
    category_entry = begin
      GetContentfulEntry.new(entry_id: category_entry_id).call
    rescue GetContentfulEntry::EntryNotFound
      send_rollbar_error(message: "A Contentful category entry was not found", entry_id: category_entry_id)
      raise
    end

    question_entry_ids = []
    category_entry.steps.each do |step|
      if question_entry_ids.include?(step.id)
        send_rollbar_error(message: "A repeated Contentful entry was found in the same journey", entry_id: step.id)
        raise RepeatEntryDetected.new(step.id)
      else
        question_entry_ids << step.id
      end
    end

    question_entry_ids.map { |entry_id|
      GetContentfulEntry.new(entry_id: entry_id).call
    }
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
