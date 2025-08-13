class AddOrganizationToSocraticSeminars < ActiveRecord::Migration[8.0]
  def up
    add_reference :socratic_seminars, :organization, foreign_key: true
    # Set existing records to organization_id = 1
    execute "UPDATE socratic_seminars SET organization_id = 1"
    # Now make the column not nullable
    change_column_null :socratic_seminars, :organization_id, false
  end

  def down
    remove_reference :socratic_seminars, :organization
  end
end
