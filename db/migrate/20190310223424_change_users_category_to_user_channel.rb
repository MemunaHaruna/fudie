class ChangeUsersCategoryToUserChannel < ActiveRecord::Migration[5.1]
  def change
    rename_table :users_categories, :user_channels
  end
end
