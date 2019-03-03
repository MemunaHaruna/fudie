class AddCommentToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :depth, :integer, null: false, default: 0
    add_reference :posts, :parent, index: true
  end
end
