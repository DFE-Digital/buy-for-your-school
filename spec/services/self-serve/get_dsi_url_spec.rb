RSpec.describe GetDsiUrl do
  subject(:service) { described_class.new(**args) }

  # TODO: replace meta-programmed testing to explicit context blocks
  describe "#call" do
    [
      {
        args: {},
        expect: "https://services.signin.education.gov.uk/",
      },
      {
        args: { subdomain: "profile" },
        expect: "https://profile.signin.education.gov.uk/",
      },
      {
        args: { path: "foo/bar" },
        expect: "https://services.signin.education.gov.uk/foo/bar",
      },
      {
        args: { subdomain: "manage", path: "foo/bar" },
        expect: "https://manage.signin.education.gov.uk/foo/bar",
      },
      {
        args: { subdomain: "manage", path: "foo/bar" },
        expect: "https://manage.signin.education.gov.uk/foo/bar",
        env: "production",
      },
      {
        args: { subdomain: "manage", path: "foo/bar" },
        expect: "https://pp-manage.signin.education.gov.uk/foo/bar",
        env: "staging",
      },
      {
        args: { subdomain: "manage", path: "foo/bar" },
        expect: "https://test-manage.signin.education.gov.uk/foo/bar",
        env: "test",
      },
    ].each do |params|
      context "with #{params[:args]}" do
        around do |example|
          ClimateControl.modify(DSI_ENV: params[:env]) { example.run }
        end

        let(:args) { params[:args] }

        it "returns #{params[:expect]}" do
          expect(service.call).to eql(params[:expect])
        end
      end
    end
  end
end
