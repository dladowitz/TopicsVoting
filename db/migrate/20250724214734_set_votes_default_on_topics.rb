class SetVotesDefaultOnTopics < ActiveRecord::Migration[8.0]
  def change
    change_column_default :topics, :votes, 0
    change_column_null :topics, :votes, false
  end
end
