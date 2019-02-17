class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :password_digest
      t.string :avatar
      t.string :username, null: false
      t.integer :role, null: false, default: 0

      t.timestamps
    end
  end
end
