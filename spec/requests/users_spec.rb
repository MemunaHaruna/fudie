require "rails_helper"

RSpec.describe "Users API", type: :request do
  let!(:user) { create(:user) }
  let(:admin_user) { create(:user, role: 1) }
  let(:headers) { valid_headers(user.id).except("Authorization") }
  let(:user_header) { valid_headers(user.id) }
  let(:admin_header) { valid_headers(admin_user.id) }
  let(:valid_attributes) do
    attributes_for(:user, password_confirmation: user.password)
  end

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

  # describe "PUT /update" do
  #   context "when a user is an admin" do
  #     context "when updating another user's role" do
  #       before { put "/users/#{user.id}", params: { role: "admin" }.to_json, headers: admin_header }

  #       it "updates successfully" do
  #         expect(json[:user][:id]).to eq user.id
  #         expect(json[:user][:role]).to eq "admin"
  #         expect(json[:message]).to eq "Account updated successfully"
  #       end
  #     end

  #     context "when updating another user's first_name or last_name" do
  #       before do
  #         put "/users/#{user.id}",
  #             params: { first_name: "josh" }.to_json, headers: admin_header
  #       end

  #       it "returns an error message" do
  #         expect(json[:message]).to eq "Sorry, you are not authorized to perform this action"
  #         expect(response).to have_http_status(403)
  #       end
  #     end

  #     context "when updating their own first_name or last_name" do
  #       before do
  #         put "/users/#{admin_user.id}",
  #             params: { first_name: "meryl", last_name: "streep" }.to_json, headers: admin_header
  #       end

  #       it "updates successfully" do
  #         expect(json[:message]).to eq "Account updated successfully"
  #         expect(json[:user][:id]).to eq admin_user.id
  #         expect(json[:user][:first_name]).to eq "meryl"
  #         expect(json[:user][:last_name]).to eq "streep"
  #       end
  #     end

  #     context "when updating their own role" do
  #       before do
  #         put "/users/#{admin_user.id}",
  #             params: { role: "member" }.to_json, headers: admin_header
  #       end

  #       it "returns an error message" do
  #         expect(json[:message]).to eq "Sorry, you are not authorized to perform this action"
  #         expect(response).to have_http_status(403)
  #       end
  #     end
  #   end

  #   context "when a user is not an admin" do
  #     context "when updating another user's role" do
  #       before do
  #         put "/users/#{admin_user.id}",
  #             params: { role: "member" }.to_json, headers: user_header
  #       end

  #       it "returns an error" do
  #         expect(json[:message]).to eq "Oops... you must be an admin to perform this action"
  #         expect(response).to have_http_status(403)
  #       end
  #     end

  #     context "when updating another user's first_name or last_name" do
  #       before do
  #         put "/users/#{admin_user.id}",
  #             params: { first_name: "gen", last_name: "nnaji" }.to_json, headers: user_header
  #       end

  #       it "returns an error" do
  #         expect(json[:message]).to eq "Sorry, you are not authorized to perform this action"
  #         expect(response).to have_http_status(403)
  #       end
  #     end

  #     context "when updating their own first_name or last_name" do
  #       before do
  #         put "/users/#{user.id}",
  #             params: { first_name: "gwara", last_name: "gwara" }.to_json, headers: user_header
  #       end

  #       it "updates successfully" do
  #         expect(json[:message]).to eq "Account updated successfully"
  #         expect(json[:user][:id]).to eq user.id
  #         expect(json[:user][:first_name]).to eq "gwara"
  #         expect(json[:user][:last_name]).to eq "gwara"
  #       end
  #     end

  #     context "when updating their own role" do
  #       before { put "/users/#{user.id}", params: { role: "admin" }.to_json, headers: user_header }

  #       it "updates successfully" do
  #         expect(json[:message]).to eq "Sorry, you are not authorized to perform this action"
  #         expect(response).to have_http_status(403)
  #       end
  #     end
  #   end
  # end

  # describe "GET /users/id" do
  #   context "when valid request" do
  #     before { get "/users/#{user.id}", headers: user_header }

  #     it "returns the user details" do
  #       expect(json[:user][:id]).to eq user.id
  #       expect(json[:user][:first_name]).to eq user.first_name
  #       expect(json[:message]).to eq "success"
  #     end
  #   end
  # end

  # describe "DELETE /users/id" do
  #   context "when deleting own account" do
  #     before { delete "/users/#{user.id}", headers: user_header }

  #     it "deletes successfully" do
  #       expect(response).to have_http_status(200)
  #       expect(json[:message]).to eq "Account deleted successfully"
  #     end
  #   end

  #   context "when deleting another user's account" do
  #     before { delete "/users/#{user.id}", headers: admin_header }

  #     it "returns an error message" do
  #       expect(json[:message]).to eq "Sorry, you are not authorized to perform this action"
  #       expect(response).to have_http_status(403)
  #     end
  #   end
  # end
end
