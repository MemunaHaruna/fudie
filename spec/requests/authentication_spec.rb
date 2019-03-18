require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "POST signin" do
    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }
    let(:headers) { valid_headers(user.id).except("Authorization") }
    let(:valid_credentials) do
      {
        email: user.email,
        password: user.password
      }.to_json
    end
    let(:invalid_credentials) do
      {
        email: user2.email,
        password: 'random'
      }.to_json
    end

    context "When request is valid" do
      context "When user account is activated" do
        before do
          user.activate
          post "/signin", params: valid_credentials, headers: headers
        end
        it "returns an authentication token" do
          expect(json[:token]).not_to be_nil
          expect(json[:message]).to eq "Successfully logged in"
        end
      end

      context "When user account is unactivated" do
        before { post "/signin", params: valid_credentials, headers: headers }
        it "returns an authentication token" do
          expect(json[:token]).to be_nil
          expect(json[:message]).to eq "Account unactivated. Check your email for activation link"
        end
      end
    end

    context "When request is invalid" do
      before do
        user2.activate
        post "/signin", params: invalid_credentials, headers: headers
      end
      it "returns a failure message" do
        expect(json["message"]).to match(/Invalid credentials/)
      end
    end
  end
end
