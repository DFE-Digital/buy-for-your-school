describe "Admin page downloads" do
  context "when the user is an analyst" do
    before do
      agent_is_signed_in(roles: %w[analyst])
      get "/admin"
    end

    it "provides an activity log CSV download" do
      get "/admin/download/user_activity.csv"
      expect(response.headers["Content-Type"]).to eq "text/csv"
      expect(response.headers["Content-Disposition"]).to match(/^attachment/)
      expect(response.headers["Content-Disposition"]).to match(/filename="user_activity_data.csv"/)
    end

    it "provides an activity log JSON download" do
      get "/admin/download/user_activity.json"
      expect(response.headers["Content-Type"]).to eq "application/json"
      expect(response.headers["Content-Disposition"]).to match(/^attachment/)
      expect(response.headers["Content-Disposition"]).to match(/filename="user_activity_data.json"/)
    end

    it "provides a users JSON download" do
      get "/admin/download/users.json"
      expect(response.headers["Content-Type"]).to eq "application/json"
      expect(response.headers["Content-Disposition"]).to match(/^attachment/)
      expect(response.headers["Content-Disposition"]).to match(/filename="user_data.json"/)
    end
  end

  context "when the user is not an analyst" do
    before do
      agent_is_signed_in(roles: %w[procops])
      get "/admin"
    end

    it "shows not authorised error" do
      expect(response).to redirect_to(cms_not_authorized_path)
    end
  end
end
