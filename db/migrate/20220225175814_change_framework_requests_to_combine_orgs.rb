class ChangeFrameworkRequestsToCombineOrgs < ActiveRecord::Migration[6.1]
  def up
    add_column :framework_requests, :org_id, :string

    ::FrameworkRequest.all.map do |fr|
      fr.update(org_id: fr.group_uid || fr.school_urn)
    end

    remove_column :framework_requests, :group_uid, :string
    remove_column :framework_requests, :school_urn, :string
  end

  def down
    add_column :framework_requests, :group_uid, :string
    add_column :framework_requests, :school_urn, :string

    ::FrameworkRequest.all.map do |fr|
      if fr.group
        fr.update!(group_uid: fr.org_id)
      else
        fr.update!(school_urn: fr.org_id)
      end
    end

    remove_column :framework_requests, :org_id, :string
  end
end
