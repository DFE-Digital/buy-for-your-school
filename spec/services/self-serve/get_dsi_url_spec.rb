RSpec.describe GetDsiUrl do
  subject(:service) { described_class.new(**args) }

  describe "#call" do
    [
      {
        args: {},
        expect: "https://test-services.signin.education.gov.uk/",
      },
      {
        args: { domain: "profile" },
        expect: "https://test-profile.signin.education.gov.uk/",
      },
      {
        args: { path: "foo/bar" },
        expect: "https://test-services.signin.education.gov.uk/foo/bar",
      },
      {
        args: { domain: "manage", path: "foo/bar" },
        expect: "https://test-manage.signin.education.gov.uk/foo/bar",
      },
      {
        args: { domain: "manage", path: "foo/bar" },
        expect: "https://manage.signin.education.gov.uk/foo/bar",
        env: "production",
      },
      {
        args: { domain: "manage", path: "foo/bar" },
        expect: "https://pp-manage.signin.education.gov.uk/foo/bar",
        env: "staging",
      },
      {
        args: { domain: "manage", path: "foo/bar" },
        expect: "https://test-manage.signin.education.gov.uk/foo/bar",
        env: "development",
      },
      {
        args: { port: 443 },
        expect: "https://test-services.signin.education.gov.uk:443/",
        env: "development",
      },
    ].each do |params|
      context "with #{params[:args]}" do
        let(:args) { params[:args] }
        let(:env) { params[:env] || "test" }

        it "returns #{params[:expect]}" do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(env))
          expect(service.call).to eql(params[:expect])
        end
      end
    end
  end
end
