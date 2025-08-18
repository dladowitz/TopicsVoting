class CreateSiteRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :site_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.timestamps

      t.index [ :user_id, :role ], unique: true
    end
  end
end
