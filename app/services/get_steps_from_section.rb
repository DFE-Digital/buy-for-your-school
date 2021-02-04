class GetStepsFromSection
  class RepeatEntryDetected < StandardError; end

  attr_accessor :section
  def initialize(section:)
    self.section = section
  end

  def call
    question_entry_ids = []
    section.steps.each do |step|
      if question_entry_ids.include?(step.id)
        send_rollbar_error(message: "A repeated Contentful entry was found in the same section", entry_id: step.id)
        raise RepeatEntryDetected.new(step.id)
      else
        question_entry_ids << step.id
      end
    end

    question_entry_ids.map { |entry_id|
      GetEntry.new(entry_id: entry_id).call
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
