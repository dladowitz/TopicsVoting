class RemoveSocraticSeminarFromTopics < ActiveRecord::Migration[8.0]
  def change
    remove_reference :topics, :socratic_seminar, null: false, foreign_key: true
  end
end
