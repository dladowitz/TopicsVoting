class AddLnurlAndTotalSatsReceivedToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :lnurl, :string
    add_column :topics, :total_sats_received, :integer
  end
end
