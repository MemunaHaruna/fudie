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

    Post.import(force: true)
    Post.__elasticsearch__.refresh_index!
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

      it "returns the right pagination metadata" do
        get "/posts", headers: headers
        expect(json[:meta][:pagination][:current_page]).to eq 1
        expect(json[:meta][:pagination][:total_records]).to eq 1
        expect(json[:meta][:pagination][:next_page]).to eq nil
        expect(json[:meta][:pagination][:prev_page]).to eq nil
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
          put "/posts/#{10013}",
              params: { title: "randooommmm" }.to_json, headers: headers

          expect(response).to have_http_status(404)
          expect(json[:message]).to eq "Couldn't find Post with 'id'=10013"
        end
      end
    end
  end

  describe "DELETE /posts/:id" do
    context "when valid params" do
      it "soft deletes the post" do
        expect(new_post.deleted_at).to eq nil

        delete "/posts/#{new_post.id}", headers: headers
        expect(response).to have_http_status(200)
        expect(new_post.reload.deleted_at).not_to eq nil
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

  describe "UPDATE /posts/:id/recover" do
    context "when valid params" do
      it "recovers the deleted post" do
        soft_delete(new_post)
        new_post.reload

        expect(new_post.deleted_at).not_to eq nil
        expect(new_post.deleted_at).to be > 4.weeks.ago # verifies that the post is not 4 weeks old yet and so is still recoverable

        put "/posts/#{new_post.id}/recover", headers: headers
        expect(new_post.reload.deleted_at).to eq nil
      end
    end

    context "when the post belongs to another user" do
      it "returns an error" do
        soft_delete(post_2)

        expect(post_2.reload.deleted_at).not_to eq nil # article has already been soft-deleted

        put "/posts/#{post_2.id}/recover", headers: headers
        expect(response).to have_http_status(403)
        expect(json[:message]).to eq "You are not authorized to perform this action"
      end
    end
  end

  private

  def soft_delete(article)
    article.update(deleted_at: Time.now) if article
  end
end
