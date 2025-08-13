class UpdateSocraticSeminarUniqueConstraint < ActiveRecord::Migration[7.0]
  def up
    # Remove the old unique index if it exists
    remove_index :socratic_seminars, :seminar_number if index_exists?(:socratic_seminars, :seminar_number)

    # Add new composite unique index
    add_index :socratic_seminars, [:organization_id, :seminar_number], unique: true
  end

  def down
    # Remove the composite index
    remove_index :socratic_seminars, [:organization_id, :seminar_number]

    # Restore the original unique index
    add_index :socratic_seminars, :seminar_number, unique: true
  end
end
