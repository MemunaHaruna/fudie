require "rails_helper"

RSpec.describe Bookmark, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:post) }
end
