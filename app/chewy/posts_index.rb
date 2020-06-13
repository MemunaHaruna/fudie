class PostsIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      title: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type Post.posts_only.published.active.includes(:user) do
    field :title, :body, :state, :deactivated_by_admin
    field :user do
      field :first_name
      field :last_name
    end
  end
end
