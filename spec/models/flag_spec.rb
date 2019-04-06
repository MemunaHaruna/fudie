require 'rails_helper'

RSpec.describe Flag, type: :model do
  before do
    user = create(:user)
    post = create(:post, user: user)
    create(:flag, :post_flag, flagger_id: user.id, flaggable_id: post.id)
  end

  it { should belong_to(:flaggable) }
  it { should validate_presence_of(:reason) }
  it { should validate_uniqueness_of(:flaggable_id).scoped_to(:flagger_id, :flaggable_type ) }
end
