class CreateToggles < ActiveRecord::Migration[8.0]
  def change
    create_table :toggles do |t|
      t.string :name, null: false
      t.integer :count, default: 0, null: false

      t.timestamps
    end
    add_index :toggles, :name, unique: true
  end
end
