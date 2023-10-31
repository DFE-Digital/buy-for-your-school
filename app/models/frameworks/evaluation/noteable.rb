module Frameworks::Evaluation::Noteable
  extend ActiveSupport::Concern

  def add_note(note)
    log_activity_event("note_added", body: note)
  end

  def latest_note
    event = Frameworks::ActivityEvent.added_notes(self).last
    return if event.nil?

    OpenStruct.new(
      body: event.loaded_data.body,
      author: event.activity_log_item.actor.initials,
      date: event.created_at.strftime("%d %b %y"),
    )
  end
end
