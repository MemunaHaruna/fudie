class CreateUsersCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :users_categories do |t|
      t.references :user, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
