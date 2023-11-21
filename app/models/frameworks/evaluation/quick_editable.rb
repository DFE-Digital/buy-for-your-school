module Frameworks::Evaluation::QuickEditable
  extend ActiveSupport::Concern

  def quick_editor(
    note: latest_note.try(:body),
    next_key_date: self.next_key_date,
    next_key_date_description: self.next_key_date_description,
    status: self.status
  )
    Frameworks::Evaluation::QuickEditor.new(
      frameworks_evaluation: self,
      note:,
      next_key_date:,
      next_key_date_description:,
      status:,
    )
  end

  def quick_edit(details = {})
    transaction do
      update!(details.except(:note)) if details.except(:note).any?
      add_note(details[:note])
    end
  end
end
