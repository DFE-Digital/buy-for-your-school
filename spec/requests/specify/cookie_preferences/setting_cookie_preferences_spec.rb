require "rails_helper"

describe "Setting cookie preferences" do
  context "when user accepts cookie usage" do
    it "sets cookie_policy cookie as accepted to expire in a years time" do
      patch cookie_preferences_path(format: :js), params: { "cookie_preferences_form[accepted_or_rejected]" => "accepted" }

      expect(response.header["Set-Cookie"]).to match(
        /cookie_policy=accepted;(.+)expires=#{1.year.from_now.strftime("%a, %d %b %Y")}/,
      )
    end
  end

  context "when user rejects cookie usage" do
    it "sets cookie_policy cookie as rejected to expire in a years time" do
      patch cookie_preferences_path(format: :js), params: { "cookie_preferences_form[accepted_or_rejected]" => "rejected" }

      expect(response.header["Set-Cookie"]).to match(
        /cookie_policy=rejected;(.+)expires=#{1.year.from_now.strftime("%a, %d %b %Y")}/,
      )
    end
  end
end
