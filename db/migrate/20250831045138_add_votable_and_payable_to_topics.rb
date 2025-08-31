class AddVotableAndPayableToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :votable, :boolean, default: true, null: false
    add_column :topics, :payable, :boolean, default: true, null: false

    add_index :topics, :votable
    add_index :topics, :payable
  end
end
