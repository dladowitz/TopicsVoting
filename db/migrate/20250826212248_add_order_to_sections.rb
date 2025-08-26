class AddOrderToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :order, :integer, null: false, default: 0
    add_index :sections, [:socratic_seminar_id, :order]
  end
end
