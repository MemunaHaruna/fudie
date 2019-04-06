require "rails_helper"

RSpec.describe "Admin::Flag API", type: :request do
  let(:user) { create(:user) }
  let(:user_2) { create(:user) }
  let(:admin_user) { create(:user, role: 1) }

  let(:flag) { create(:flag, :user_flag, flagger_id: admin_user.id, flaggable_id: user.id)}

  let(:update_params) { { reviewed_by_admin: true } }

  let(:headers) { valid_headers(user.id) }
  let(:admin_headers) { valid_headers(admin_user.id) }


  before do
    user.activate
    admin_user.activate
  end

  describe "INDEX /flags" do
    context "when the user is not an admin" do
      it "returns an error" do
        get "/admin/flags", headers: headers

        expect(json[:message]).to eq "You are not authorized to perform this action"
        expect(response).to have_http_status(403)
      end
    end

    context "when the user is an admin" do
      it "returns the list of flags" do
        create(:flag, :user_flag, flagger_id: user.id, flaggable_id: user_2.id)
        create(:flag, :user_flag, flagger_id: admin_user.id, flaggable_id: user_2.id)

        get "/admin/flags", headers: admin_headers

        expect(json[:flags].count).to eq 2
        expect(json[:flags].first[:flagger_id]).to eq user.id
        expect(json[:flags].first[:flaggable][:id]).to eq user_2.id

        expect(json[:flags].second[:flagger_id]).to eq admin_user.id
        expect(json[:flags].first[:flaggable][:id]).to eq user_2.id
      end
    end
  end

  describe "SHOW /flag" do
    context "when the flag exists" do
      it "returns the flag" do
        get "/admin/flags/#{flag.id}", headers: admin_headers

        expect(json[:flag][:id]).to eq flag.id
        expect(json[:flag][:flagger_id]).to eq flag.flagger_id
        expect(json[:flag][:flaggable][:id]).to eq user.id
        expect(json[:flag][:reason]).to eq flag.reason
      end
    end

    context "when the flag does not exist" do
      it "returns an flag" do
        get "/admin/flags/20", headers: admin_headers

        expect(json[:message]).to eq "Couldn't find Flag with 'id'=20"
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "UPDATE /flag" do
    context "when valid params" do
      it "updates successfully" do
        expect(flag.reviewed_by_admin).to eq false
        expect(flag.flaggable.id).to eq user.id
        expect(flag.flaggable.active).to eq true

        put "/admin/flags/#{flag.id}", params: { deactivated_by_admin: true }.to_json, headers: admin_headers

        expect(json[:flag][:reviewed_by_admin]).to eq true
        expect(json[:flag][:flaggable][:id]).to eq user.id
        expect(json[:flag][:flaggable][:active]).to eq false
        expect(response).to have_http_status(200)
      end
    end

    context "when invalid params" do
      it "updates with default value" do
        expect(flag.reviewed_by_admin).to eq false
        expect(flag.flaggable.id).to eq user.id
        expect(flag.flaggable.active).to eq true

        put "/admin/flags/#{flag.id}", params: { random: true }.to_json, headers: admin_headers

        expect(json[:flag][:reviewed_by_admin]).to eq true
        expect(json[:flag][:flaggable][:id]).to eq user.id
        expect(json[:flag][:flaggable][:active]).to eq true
      end
    end

    context "when user is not admin" do
      it "returns an error" do
        put "/admin/flags/#{flag.id}", params: { random: true }.to_json, headers: headers

        expect(json[:message]).to eq "You are not authorized to perform this action"
        expect(response).to have_http_status(403)
      end
    end
  end
end
