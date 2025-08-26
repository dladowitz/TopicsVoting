class UpdatePayoutsTable < ActiveRecord::Migration[8.0]
  def change
    # Rename bolt12_invoice to invoice
    rename_column :payouts, :bolt12_invoice, :invoice

    # Add invoice_type column
    add_column :payouts, :invoice_type, :string

    # Add index on invoice_type for better performance
    add_index :payouts, :invoice_type
  end
end
