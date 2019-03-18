require "rails_helper"

RSpec.describe "Post API", type: :request do
  let!(:user) { create(:user, role: 1) }
  let!(:user_2) { create(:user, email: 'foo@bar.com', username: 'username') }
  let!(:headers) { valid_headers(user.id) }
  let!(:new_post) { create(:post, user: user) }
  let!(:headers_2) { valid_headers(user_2.id) }
  let!(:valid_params) { valid_post_params.merge(user_id: user.id) }
  let(:duplicate_params) { valid_params.merge(user_id: user.id, title: new_post.title) }
  let(:invalid_post_params1) { invalid_post_params_1.merge(user_id: user.id) }
  let(:invalid_post_params2) {invalid_post_params_2.merge(user_id: user.id)}
  let(:post_2) { create(:post, user: user_2)}

  before do
    user.activate
    user_2.activate
  end

  describe "POST /posts" do
    context "when valid params" do
      it "creates a new post" do
        post "/posts", params: valid_params.to_json, headers: headers

        expect(json[:message]).to eq "Post created successfully"
        expect(json[:post][:title]).to eq valid_params[:title]
        expect(json[:post][:body]).to eq valid_params[:body]
        expect(json[:post][:state]).to eq 'published'
        expect(response).to have_http_status(201)
      end
    end

    context "when invalid params" do
      context "when title is empty" do
        it "returns an error" do
          post "/posts", params: invalid_post_params1.to_json,
          headers: headers
          expect(response).to have_http_status(422)
          expect(json[:errors][:title]).to include "can't be blank"
        end
      end

      context "when content is empty" do
        it "returns an error" do
          post "/posts", params: invalid_post_params2.to_json,
          headers: headers

          expect(response).to have_http_status(422)
          expect(json[:errors][:body]).to include "can't be blank"
        end
      end

      context "when that user already has a post with same title" do
        before do
          Post.create(duplicate_params)
        end

        it "returns an error" do
          post "/posts",
          params: duplicate_params.to_json, headers: headers
          expect(json[:errors][:title]).to include "has already been taken"
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe "GET /posts" do
    context "when admin user" do
      it "returns the user's posts and other user's published posts" do
        get "/posts", headers: headers

        expect(json[:posts].first[:title]).to eq new_post[:title]
        expect(json[:posts].first[:state]).to eq new_post[:state]
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "PUT /posts/:id" do
    context "when updating another user's posts" do
      it "returns an error message" do
        put "/posts/#{new_post.id}",
        params: { title: "randooommmm" }.to_json, headers: headers_2

        expect(json[:message]).to eq "You are not authorized to perform this action"
        expect(response).to have_http_status(403)
      end
    end

    context "when valid params" do
      it "updates the post" do
        put "/posts/#{new_post.id}",
        params: { title: "randooommmm" }.to_json, headers: headers

        expect(new_post.reload.title).to eq "randooommmm"
        expect(json[:message]).to eq "Post updated successfully"
        expect(response).to have_http_status(200)
      end
    end

    context "when invalid params" do
      context "when post does not exist" do
        it "returns an error" do
          put "/posts/#{13}",
              params: { title: "randooommmm" }.to_json, headers: headers

          expect(response).to have_http_status(404)
          expect(json[:message]).to eq "Couldn't find Post with 'id'=13"
        end
      end
    end
  end

  describe "DELETE /posts/:id" do
    context "when valid params" do
      it "deletes the post" do
        delete "/posts/#{new_post.id}", headers: headers
        expect(response).to have_http_status(204)
      end
    end

    context "when invalid params" do
      context "when post does not exist" do
        it "returns an error" do
          delete "/posts/#{200}", headers: headers

          expect(response).to have_http_status(404)
          expect(json[:message]).to eq "Couldn't find Post with 'id'=200"
        end
      end

      context "when the post belongs to another user" do
        it "returns an error" do

          delete "/posts/#{post_2.id}", headers: headers

          expect(response).to have_http_status(403)
          expect(json[:message]).to eq "You are not authorized to perform this action"
        end
      end
    end
  end
end
