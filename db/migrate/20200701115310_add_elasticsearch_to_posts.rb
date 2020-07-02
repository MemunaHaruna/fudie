class AddElasticsearchToPosts < ActiveRecord::Migration[5.2]
  def up
    Post.import(force: true)
  end

  def down
    Post.__elasticsearch__.delete_index!
  end
end
