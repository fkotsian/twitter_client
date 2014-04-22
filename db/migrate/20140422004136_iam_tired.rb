class IamTired < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.text :body, null: false
      t.string :twitter_status_id, null: false, uniq: true
      t.string :twitter_user_id, null: false
      t.timestamps
    end
  end
end
