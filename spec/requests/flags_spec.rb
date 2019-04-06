require "rails_helper"

RSpec.describe "Flag API", type: :request do
  let(:user) { create(:user)}
  let(:user_2) { create(:user)}

  let(:new_post) { create(:post, user: user) }
  let(:new_post_2) { create(:post, user: user_2) }


  let(:invalid_post_flag) { post_flag(flagger_id: user.id, flaggable_id: new_post.id) }

  let(:valid_post_flag) { post_flag(flagger_id: user.id, flaggable_id: new_post_2.id) }

  let(:invalid_user_flag) { user_flag(flagger_id: user.id, flaggable_id: user.id) }

  let(:valid_user_flag) { user_flag(flagger_id: user.id, flaggable_id: user_2.id) }

  let(:invalid_flag_1) {
    invalid_flag(flagger_id: user.id, flaggable_id: user_2.id)
  }

  let(:invalid_flag_2) {
    user_flag(flagger_id: user.id, flaggable_id: user_2.id).except(:reason)
  }

  let(:invalid_flag_3) {
    post_flag(flagger_id: user.id, flaggable_id: new_post_2.id).except(:flaggable_type)
  }

  let(:headers) { valid_headers(user.id) }
  let(:headers_2) { valid_headers(user_2.id) }

  before do
    user.activate
    user_2.activate
  end

  describe "POST /flags" do
    context "when params is valid for a Post type flag" do
      it "flags the specified post successfully" do
        post "/flags", params: valid_post_flag.to_json, headers: headers

        expect(json[:flag][:reason]).to eq valid_post_flag[:reason]
        expect(json[:flag][:flagger_id]).to eq valid_post_flag[:flagger_id]
        expect(json[:flag][:flaggable][:id]).to eq new_post_2.id
      end
    end

    context "when params is valid for a User type flag" do
      it "flags the specified user successfully" do
        post "/flags", params: valid_user_flag.to_json, headers: headers

        expect(json[:flag][:reason]).to eq valid_user_flag[:reason]
        expect(json[:flag][:flagger_id]).to eq valid_user_flag[:flagger_id]
        expect(json[:flag][:flaggable][:id]).to eq user_2.id
      end
    end

    context "when a user tries to flag their own post" do
      it "returns an error" do
        post "/flags", params: invalid_post_flag.to_json, headers: headers

        expect(response).to have_http_status(403)
        expect(json[:message]).to eq "You are not permitted to perform this action"
      end
    end

    context "when a user tries to flag their self" do
      it "returns an error" do
        post "/flags", params: invalid_user_flag.to_json, headers: headers

        expect(response).to have_http_status(403)
        expect(json[:message]).to eq "You are not permitted to perform this action"
      end
    end

    context "when the user does not provide a reason for flagging a post/user" do
      it "returns an error" do
        post "/flags", params: invalid_flag_2.to_json, headers: headers

        expect(response).to have_http_status(422)
        expect(json[:message]).to eq "Validation failed: Reason can't be blank"
      end
    end

    context "when flagable_type in params is not post or user" do
      it "returns an error" do
        post "/flags", params: invalid_flag_1.to_json, headers: headers

        expect(response).to have_http_status(422)
        expect(json[:message]).to eq "Unable to flag record type"
      end
    end

    context "when flagable_type is missing from params" do
      it "returns an error" do
        post "/flags", params: invalid_flag_3.to_json, headers: headers

        expect(response).to have_http_status(422)
        expect(json[:message]).to eq "Flag type must be specified"
      end
    end
  end
end
