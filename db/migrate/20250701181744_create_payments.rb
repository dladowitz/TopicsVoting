class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :topic, foreign_key: true
      t.string :payment_hash
      t.integer :amount
      t.boolean :paid, default: false
      t.timestamps
    end
  end
end
