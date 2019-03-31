class RemoveAvatarFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :avatar, :string
  end
end
