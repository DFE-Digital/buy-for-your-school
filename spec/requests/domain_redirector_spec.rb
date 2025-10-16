require "rails_helper"

RSpec.describe DomainRedirector do
  let(:app) { ->(env) { [200, env, "OK"] } }
  let(:middleware) { described_class.new(app) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("APPLICATION_URL").and_return("https://new.get-help-buying-for-schools.education.gov.uk,https://old.get-help-buying-for-schools.service.gov.uk")
  end

  context "when host matches old domain" do
    let(:env) { { "HTTP_HOST" => "old.get-help-buying-for-schools.service.gov.uk" } }
    let(:response) { middleware.call(env) }
    let(:status) { response[0] }
    let(:headers) { response[1] }

    it "returns 301 status" do
      expect(status).to eq(301)
    end

    it "redirects to new domain" do
      location = URI.parse(headers["Location"])
      expect(location.host).to eq("new.get-help-buying-for-schools.education.gov.uk")
      expect(location.path).to eq("/")
    end
  end

  context "when host matches new domain" do
    let(:env) { { "HTTP_HOST" => "new.get-help-buying-for-schools.education.gov.uk" } }
    let(:response) { middleware.call(env) }
    let(:status) { response[0] }

    it "returns 200 status" do
      expect(status).to eq(200)
    end
  end
end
