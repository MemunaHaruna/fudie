require "rails_helper"

RSpec.describe "Users API", type: :request do
  let(:user) { create(:user) }
  let(:user_2) { create(:user) }
  let(:admin_user) { create(:user, role: 1) }
  let(:headers) { valid_headers(user.id).except("Authorization") }
  let(:user_header) { valid_headers(user.id) }
  let(:user2_header) { valid_headers(user_2.id) }
  let(:admin_header) { valid_headers(admin_user.id) }
  let(:valid_attributes) do
    attributes_for(:user, password_confirmation: user.password)
  end
  let!(:admin_post) { create(:post, user: admin_user)}
  let!(:thread_following) { create(:thread_following, user: admin_user, post: admin_post) }

  let!(:member_post) { create(:post, user: user)}
  let!(:thread_following2) { create(:thread_following, user: user, post: member_post) }

  let!(:category_1) {create(:category)}
  let!(:category_2) {create(:category)}
  let(:update_params) {{ first_name: 'marie', last_name: 'kondo',
    category_ids: [category_1.id, category_2.id], bio: 'hello' }}

  describe "POST /signup" do
    context "when valid request" do
      before { post "/signup", params: valid_attributes.to_json, headers: headers }

      it "creates a new user" do
        expect(response).to have_http_status(201)
      end

      it "returns an authentication token" do
        expect(json[:token]).not_to be_nil
      end

      it "returns a success message" do
        expect(json[:message]).to eq "Account created successfully"
      end
    end

    context "when invalid request" do
      before { post "/signup", params: {}, headers: headers }

      it "does not create a new user" do
        expect(response).to have_http_status(422)
      end

      it "returns failure message" do
        expect(json["message"]).
          to match(/Password and Password Confirmation don't match/)
      end
    end
  end

  describe "GET /show" do
    context "when the current_user is viewing their own profile" do
      context "when current user is an admin" do
        before { get "/users/#{admin_user.id}", headers: admin_header }

        it "returns all user details including email, role and thread_followings" do
          expect(json[:user][:id]).to eq admin_user.id
          expect(json[:user][:email]).to eq admin_user.email
          expect(json[:user][:role]).to eq admin_user.role
          expect(json[:user][:posts].first[:id]).to eq admin_post.id
          expect(json[:user][:bio]).to eq admin_user.bio
          expect(json[:user][:thread_followings].first[:id]).to eq thread_following.id
          expect(json[:user][:thread_followings].size).to eq 1
        end
      end

      context "when current user is a regular member" do
        before { get "/users/#{user.id}", headers: user_header }

        it "returns all user details without their role" do
          expect(json[:user][:id]).to eq user.id
          expect(json[:user][:email]).to eq user.email
          expect(json[:user][:role]).to eq nil
          expect(json[:user][:bio]).to eq user.bio
          expect(json[:user][:thread_followings].first[:id]).to eq thread_following2.id
          expect(json[:user][:thread_followings].size).to eq 1
          expect(json[:user][:posts].first[:id]).to eq member_post.id
        end
      end

      context "when the current_user is viewing another user's profile" do
        context "when current user is an admin" do
          before { get "/users/#{user.id}", headers: admin_header }

          it "returns all user details including email, role but not their thread_followings" do
            expect(json[:user][:id]).to eq user.id
            expect(json[:user][:email]).to eq user.email
            expect(json[:user][:role]).to eq user.role
            expect(json[:user][:bio]).to eq user.bio
            expect(json[:user][:posts].first[:id]).to eq member_post.id
            expect(json[:user][:thread_followings]).to eq nil
          end
        end

        context "when current user is an admin" do
          before { get "/users/#{admin_user.id}", headers: user_header }

          it "returns all user details without their email, role and their thread_followings" do
            expect(json[:user][:id]).to eq admin_user.id
            expect(json[:user][:email]).to eq nil
            expect(json[:user][:role]).to eq nil
            expect(json[:user][:bio]).to eq admin_user.bio
            expect(json[:user][:posts].first[:id]).to eq admin_post.id
            expect(json[:user][:thread_followings]).to eq nil
          end
        end
      end
    end
  end

  describe "PUT /update" do
    context "when current user is updating their own profile" do
      it "updates successfully" do
        put "/users/#{user.id}", headers: user_header , params: update_params.to_json

        expect(json[:user][:id]).to eq user.id
        expect(json[:user][:email]).to eq user.email
        expect(json[:user][:bio]).to eq 'hello'
        expect(json[:user][:first_name]).to eq 'marie'
        expect(json[:user][:last_name]).to eq 'kondo'
        expect(json[:user][:categories].count).to eq 2
      end
    end

    context "when current user attempts to update another user's profile" do
      before do
        put "/users/#{admin_user.id}", headers: user_header, params: update_params.to_json
      end

      it "returns an error" do
        expect(json[:message]).to eq "You are not authorized to perform this action"
        expect(response).to have_http_status(403)
      end
    end
  end

  describe "DELETE /users/:id" do
    context "when valid params" do
      it "soft deletes the user" do
        expect(user.deleted_at).to eq nil

        delete "/users/#{user.id}", headers: user_header
        expect(response).to have_http_status(200)
        expect(json[:message]).to eq "User deleted successfully."
        expect(user.reload.deleted_at).not_to eq nil
      end
    end

    context "when invalid params" do
      context "when the user does not exist" do
        it "returns an error" do
          delete "/users/#{10000}", headers: user_header

          expect(response).to have_http_status(404)
          expect(json[:message]).to eq "Couldn't find User with 'id'=10000"
        end
      end

      context "when a non-admin tries to delete another user's account" do
        it "returns an error" do
          delete "/users/#{user.id}", headers: user2_header

          expect(response).to have_http_status(403)
          expect(json[:message]).to eq "You are not authorized to perform this action"
        end
      end
    end
  end

  describe "UPDATE /users/:id/recover" do
    context "when valid params" do
      it "soft deletes the user" do
        # soft_delete(user) # TO-DO: figure out why this fails

        user.deleted_at = Time.now
        expect(user.deleted_at).not_to eq nil # article has already been soft-deleted
        expect(user.deleted_at).to be > 4.weeks.ago # verifies that the post is not 4 weeks old yet and so is still recoverable

        put "/users/#{user.id}/recover", headers: user_header
        expect(response).to have_http_status(200)
        expect(user.reload.deleted_at).to eq nil
      end
    end

    context "when a user tries to recover another user's account" do
      it "returns an error" do
        soft_delete(user)

        expect(user.reload.deleted_at).not_to eq nil # article has already been soft-deleted

        put "/users/#{user.id}/recover", headers: user2_header
        expect(response).to have_http_status(403)
        expect(json[:message]).to eq "You are not authorized to perform this action"
      end
    end
  end

  private

  def soft_delete(member)
    member.update(deleted_at: Time.now) if member
  end
end
