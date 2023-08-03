module Support::Case::QuickEditable
  extend ActiveSupport::Concern

  def quick_editor(params = { note: latest_note&.body, support_level:, procurement_stage_id:, with_school: })
    Support::Case::QuickEditor.new(support_case: self, **params)
  end

  def quick_edit(details)
    transaction do
      update!(details.except(:note))
      add_note(details.fetch(:note)) if details[:note].present? && details[:note] != latest_note&.body
    end
  end
end
