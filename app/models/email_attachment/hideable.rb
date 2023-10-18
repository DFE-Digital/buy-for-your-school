module EmailAttachment::Hideable
  extend ActiveSupport::Concern

  def hide
    self.class.find_duplicates_of(self).update(hidden: true)
  end
end
