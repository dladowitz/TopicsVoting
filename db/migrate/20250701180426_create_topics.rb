class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.string :lnurl
      t.integer :sats_received, null: false, default: 0

      t.timestamps
    end
  end
end
