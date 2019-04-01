class CreateFlags < ActiveRecord::Migration[5.2]
  def change
    create_table :flags do |t|
      t.references :flaggable, polymorphic: true, index: true
      t.text :reason, null: false
      t.boolean :reviewed_by_admin, null: false, default: false
      t.integer :flagger_id, index: true

      t.timestamps
    end
  end
end
