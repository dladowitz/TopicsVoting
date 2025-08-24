class AddBolt12InvoiceToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :bolt12_invoice, :text
  end
end
