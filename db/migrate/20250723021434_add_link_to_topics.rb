class AddLinkToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :link, :string
  end
end
