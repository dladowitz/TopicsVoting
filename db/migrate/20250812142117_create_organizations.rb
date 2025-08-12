class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :city
      t.string :country, limit: 2
      t.string :website
      t.timestamps
    end
  end
end
