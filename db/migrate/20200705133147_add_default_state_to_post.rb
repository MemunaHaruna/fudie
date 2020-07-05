class AddDefaultStateToPost < ActiveRecord::Migration[5.2]
  def change
    change_column_default :posts, :state, 0
  end
end
