require "rails_helper"

RSpec.describe FafDomainRedirect do
  let(:app) { ->(env) { [200, env, "OK"] } }
  let(:middleware) { described_class.new(app) }
  let(:faf_domain) { "find-dfe-approved-framework.service.gov.uk" }
  let(:app_domain) { "get-help-buying-for-schools.education.gov.uk" }

  before do
    allow(ENV).to receive(:fetch).with("FAF_DOMAIN", nil).and_return(faf_domain)
    allow(ENV).to receive(:[]).with("APP_DOMAIN").and_return(app_domain)
  end

  context "when host matches FAF_DOMAIN" do
    let(:env) { { "HTTP_HOST" => faf_domain, "PATH_INFO" => "/test", "QUERY_STRING" => "param=value" } }
    let(:response) { middleware.call(env) }
    let(:status) { response[0] }
    let(:headers) { response[1] }

    it "returns 301 status" do
      expect(status).to eq(301)
    end

    it "redirects to root path on app domain" do
      location = URI.parse(headers["Location"])
      expect(location.host).to eq(app_domain)
      expect(location.path).to eq("/")
    end
  end
end
