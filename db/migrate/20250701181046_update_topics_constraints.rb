class UpdateTopicsConstraints < ActiveRecord::Migration[8.0]
  def change
    change_column_null :topics, :name, false
    change_column_default :topics, :sats_received, 0
    change_column_null :topics, :sats_received, false
  end
end
