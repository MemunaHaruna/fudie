require "rails_helper"

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password_digest) }

  it { should have_many(:posts) }
  it { should have_many(:categories) }
end
