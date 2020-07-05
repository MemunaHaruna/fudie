require "rails_helper"

RSpec.describe Post, elasticsearch: true, type: :model do
  before do
    user = create(:user)
    create(:post, user: user)
  end

  it { should validate_uniqueness_of(:title).scoped_to(:user_id) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  it { should belong_to(:user) }
  it { should have_many(:comments) }
  it { should have_many(:categories) }
  it { should have_many(:votes) }
  it { should have_many(:bookmarks) }
  it { should have_many(:thread_followings) }

  it 'should be indexed' do
    Post.create!(post_params)

    # refresh the index
    Post.__elasticsearch__.refresh_index!

    # verify the model was indexed
    expect(Post.search('elasticsearch elasticsearch index').records.length).to eq(1)
  end

  private

  def post_params
    { title: 'test elasticsearch index',
      body: 'test body',
      user_id: User.first.id,
      state: 1
    }
  end
end
