class AddVotesToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :votes, :integer
  end
end
