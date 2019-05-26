require "rails_helper"

RSpec.describe "Votes API", type: :request do
  let(:user) { create(:user)}
  let(:user_2) { create(:user)}

  let(:new_post) { create(:post, user: user) }
  let(:new_post_2) { create(:post, user: user_2) }

  let(:headers) { valid_headers(user.id) }
  let(:headers_2) { valid_headers(user_2.id) }
  let!(:new_vote) { create(:vote, user: user_2, post: new_post) }

  before do
    user.activate
    user_2.activate
  end

  describe "POST /votes" do
    context "upvoting a post" do
      it "creates the upvote successfully" do
        post "/votes", params: {post_id: new_post_2.id, vote_type: 'upvote'}.to_json, headers: headers

        expect(json[:vote][:vote_type]).to eq 'upvote'
        expect(json[:vote][:post][:id]).to eq new_post_2.id
        expect(json[:vote][:user][:id]).to eq user.id
      end
    end

    context "downvoting a post" do
      it "creates the downvote successfully" do
        post "/votes", params: {post_id: new_post.id, vote_type: 'downvote'}.to_json, headers: headers

        expect(json[:vote][:vote_type]).to eq 'downvote'
        expect(json[:vote][:post][:id]).to eq new_post.id
        expect(json[:vote][:user][:id]).to eq user.id
      end
    end

    context "multiple votes for the same post by same user" do
      it "returns an error message" do
        post "/votes", params: {post_id: new_post.id, vote_type: 'downvote'}.to_json, headers: headers_2

        expect(json[:message]).to eq "Validation failed: Post has already been taken"
        expect(json[:errors]).not_to be_nil
      end
    end

    context "invalid vote_type" do
      it "returns an error message" do
        post "/votes", params: {post_id: new_post.id, vote_type: 'random'}.to_json, headers: headers_2

        expect(json[:message]).to eq "'random' is not a valid vote_type"
        expect(json[:errors]).not_to be_nil
      end
    end
  end

  describe "PUT /votes/:id" do
    context "when updating a vote" do
      it "successfully updates the vote" do
        put "/votes/#{new_vote.id}", params: {vote_type: 'upvote'}.to_json, headers: headers_2

        expect(json[:vote][:id]).to eq new_vote.id
        expect(json[:vote][:vote_type]).to eq 'upvote'
        expect(json[:vote][:user][:id]).to eq new_vote.user.id
        expect(json[:vote][:post][:id]).to eq new_vote.post.id
      end
    end

    context "multiple upvotes/downvotes by the same user" do
      it "returns an error message" do
        put "/votes/#{new_vote.id}", params: {vote_type: 'downvote'}.to_json, headers: headers_2

        expect(json[:message]).to eq "Multiple downvotes not allowed"
      end
    end
  end
end
