class AddUniqueIndexToTopicsId < ActiveRecord::Migration[8.0]
  def change
    add_index :topics, :id, unique: true
  end
end
