class AddDeletedAtColumnToPostsAndUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
  end
end
