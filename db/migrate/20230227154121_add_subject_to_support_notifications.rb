class AddSubjectToSupportNotifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :support_notifications, :subject, polymorphic: true, index: true, type: :uuid
  end
end
