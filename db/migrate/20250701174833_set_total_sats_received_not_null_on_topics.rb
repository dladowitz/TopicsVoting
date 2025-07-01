class SetTotalSatsReceivedNotNullOnTopics < ActiveRecord::Migration[7.1]
  def change
    change_column_null :topics, :total_sats_received, false
  end
end
