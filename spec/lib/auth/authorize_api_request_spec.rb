require "rails_helper"

RSpec.describe Auth::AuthorizeApiRequest do
  let(:user) { create(:user) }
  let(:header) { { "Authorization" => token_generator(user.id) } }
  subject(:invalid_request_object) { described_class.new({}) }
  subject(:valid_request_object) { described_class.new(header) }

  describe "#call" do
    context "when invalid request" do
      context "when token is missing" do
        it "raises a MissingToken error" do
          expect { invalid_request_object.call }.to raise_error(ExceptionHandler::MissingToken, 'Missing Token')
          end
      end

      context "when token is invalid" do
        let(:incorrect_header) { { "Authorization" => "Bearer #{token_generator('hello')}" } }

        subject(:invalid_object) { described_class.new(incorrect_header) }

        it "raises an InvalidToken error" do
          expect { invalid_object.call }.to raise_error(
            ExceptionHandler::InvalidToken, 'Invalid Token'
          )
        end
      end

      context "when token is fake" do
      end
    end

    context "when valid request" do
      it "returns user object" do
        result = valid_request_object.call

        expect(result[:user]).to eq user
      end
    end
  end
end
