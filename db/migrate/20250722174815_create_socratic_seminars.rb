class CreateSocraticSeminars < ActiveRecord::Migration[8.0]
  def change
    create_table :socratic_seminars do |t|
      t.integer :seminar_number
      t.date :date

      t.timestamps
    end
    add_index :socratic_seminars, :seminar_number, unique: true
  end
end
