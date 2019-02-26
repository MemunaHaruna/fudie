class AddActivationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :account_activation_digest, :string
    add_column :users, :account_activated, :boolean, default: false
    add_column :users, :account_activated_at, :datetime
  end
end
