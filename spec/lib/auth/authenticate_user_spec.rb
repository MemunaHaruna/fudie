require "rails_helper"

RSpec.describe Auth::AuthenticateUser do
  let(:user) { create(:user) }
  subject(:valid_auth_obj) { described_class.new(user.email, user.password) }
  subject(:invalid_auth_obj) { described_class.new("foo", "bar") }

  describe "#call" do
    context "when valid credentials" do
      it "returns an auth token" do
        token = valid_auth_obj.call
        auth_token = Auth::JsonWebToken.encode(user_id: user.id)

        expect(token).not_to be_nil
        expect(token).to eq auth_token
      end
    end

    context "when invalid credentials" do
      it "raises an authentication error" do
        expect { invalid_auth_obj.call }.
          to raise_error(
            ExceptionHandler::AuthenticationError,
            /Invalid credentials/
          )
      end
    end
  end
end
