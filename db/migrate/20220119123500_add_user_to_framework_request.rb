class AddUserToFrameworkRequest < ActiveRecord::Migration[6.1]
  def change
    add_reference :framework_requests, :user, foreign_key: true, type: :uuid
  end
end
