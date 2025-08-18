class CreateOrganizationRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps

      t.index [:user_id, :organization_id, :role], unique: true, name: 'index_org_roles_on_user_org_and_role'
    end
  end
end
