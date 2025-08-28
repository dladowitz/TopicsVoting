class AddAllowPublicSubmissionsToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :allow_public_submissions, :boolean, default: false
  end
end
