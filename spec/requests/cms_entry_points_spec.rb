require "rails_helper"

describe "CMS Entry points" do
  {
    %w[e_and_o] => "/engagement",
    %w[procops] => "/support",
    [] => "/cms/no_roles_assigned",
  }.each do |roles, expected_redirect_path|
    it "redirects agents with roles #{roles.join(', ')} to #{expected_redirect_path}" do
      agent_is_signed_in(roles:)
      get "/cms"
      expect(response).to redirect_to(expected_redirect_path)
    end
  end
end
