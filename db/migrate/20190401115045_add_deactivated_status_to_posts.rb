class AddDeactivatedStatusToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :deactivated_by_admin, :boolean, null: false, default: false
  end
end
