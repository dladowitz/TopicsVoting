class CreatePayouts < ActiveRecord::Migration[8.0]
  def change
    create_table :payouts do |t|
      t.references :socratic_seminar, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.integer :amount
      t.text :bolt12_invoice
      t.string :payment_hash
      t.string :status
      t.text :memo
      t.json :lnbits_response

      t.timestamps
    end
  end
end
