class ChangeDefaultForTotalSatsReceivedInTopics < ActiveRecord::Migration[7.1]
  def change
    change_column_default :topics, :total_sats_received, 0
  end
end
