class MigrateUserRolesToSiteRoles < ActiveRecord::Migration[8.0]
  def up
    # Create site_roles for admin users
    User.where(role: 'admin').find_each do |user|
      SiteRole.create!(user: user, role: 'admin')
    end

    # Remove the role column from users
    remove_column :users, :role
  end

  def down
    # Add back the role column
    add_column :users, :role, :string, default: 'participant'

    # Restore admin roles
    SiteRole.find_each do |site_role|
      site_role.user.update_column(:role, site_role.role)
    end

    # Drop the site_roles table (this is handled by the other migration rollback)
  end
end
