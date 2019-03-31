require "rails_helper"

RSpec.describe Post, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  # it { should validate_uniqueness_of(:title).scoped_to(:user_id) }
  it { should belong_to(:user) }
  it { should have_many(:comments) }
  it { should have_many(:categories) }
  it { should have_many(:votes) }
  it { should have_many(:bookmarks) }
  it { should have_many(:thread_followings) }
end
