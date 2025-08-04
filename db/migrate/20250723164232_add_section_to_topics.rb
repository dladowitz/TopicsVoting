class AddSectionToTopics < ActiveRecord::Migration[8.0]
  def change
    add_reference :topics, :section, null: false, foreign_key: true
  end
end
