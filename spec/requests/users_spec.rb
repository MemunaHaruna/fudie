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
end
