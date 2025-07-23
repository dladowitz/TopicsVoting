class AddBuilderSfLinkToSocraticSeminars < ActiveRecord::Migration[8.0]
  def change
    add_column :socratic_seminars, :builder_sf_link, :string
  end
end
