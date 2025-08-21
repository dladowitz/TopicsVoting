class RenameBuilderSfLinkToTopicsListUrl < ActiveRecord::Migration[8.0]
  def change
    rename_column :socratic_seminars, :builder_sf_link, :topics_list_url
  end
end
