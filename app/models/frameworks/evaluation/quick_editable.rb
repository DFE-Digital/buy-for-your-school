module Frameworks::Evaluation::QuickEditable
  extend ActiveSupport::Concern

  def quick_editor(note: latest_note&.body, next_key_date: self.next_key_date, next_key_date_description: self.next_key_date_description)
    Frameworks::Evaluation::QuickEditor.new(frameworks_evaluation: self, note:, next_key_date:, next_key_date_description:)
  end

  def quick_edit(details)
    transaction do
      update!(details.except(:note))
      add_note(details[:note]) if details[:note].present? && details[:note] != latest_note&.body
    end
  end
end
