class AddParentTopicIdToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :parent_topic_id, :integer
    add_index :topics, :parent_topic_id
  end
end
