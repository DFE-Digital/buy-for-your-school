class CreateJoinTableSchoolsUsers < ActiveRecord::Migration[6.1]
  def change
    create_join_table :schools, :users do |t|
      t.index %i[school_id user_id]
      t.index %i[user_id school_id]
    end
  end
end
