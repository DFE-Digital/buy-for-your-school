require "dsi/uri"

RSpec.describe Dsi::Uri do
  subject(:service) { described_class.new(**args) }

  # TODO: replace meta-programmed testing to explicit context blocks
  describe "#call" do
    context "with a DSI_ENV of production" do
      let(:args) { { env: "production" } }

      %w[services api oidc].each do |subdomain|
        context "and given a subdomain of #{subdomain}" do
          let(:args) { super().merge(subdomain: subdomain) }

          context "with a path of foo" do
            let(:args) { super().merge(path: "foo") }

            it { expect(service.call).to eql URI("https://#{subdomain}.signin.education.gov.uk/foo") }
          end

          context "with no path" do
            it { expect(service.call).to eql URI("https://#{subdomain}.signin.education.gov.uk/") }
          end
        end
      end

      context "and given no subdomin" do
        context "with a path of foo" do
          let(:args) { super().merge(path: "foo") }

          it { expect(service.call).to eql URI("https://services.signin.education.gov.uk/foo") }
        end

        context "with no path" do
          it { expect(service.call).to eql URI("https://services.signin.education.gov.uk/") }
        end
      end
    end

    context "with a DSI_ENV of staging" do
      let(:args) { { env: "staging" } }

      %w[services api oidc].each do |subdomain|
        context "and given a subdomain of #{subdomain}" do
          let(:args) { super().merge(subdomain: subdomain) }

          context "with a path of foo" do
            let(:args) { super().merge(path: "foo") }

            it { expect(service.call).to eql URI("https://pp-#{subdomain}.signin.education.gov.uk/foo") }
          end

          context "with no path" do
            it { expect(service.call).to eql URI("https://pp-#{subdomain}.signin.education.gov.uk/") }
          end
        end
      end

      context "and given no subdomin" do
        context "with a path of foo" do
          let(:args) { super().merge(path: "foo") }

          it { expect(service.call).to eql URI("https://pp-services.signin.education.gov.uk/foo") }
        end

        context "with no path" do
          it { expect(service.call).to eql URI("https://pp-services.signin.education.gov.uk/") }
        end
      end
    end

    context "with a DSI_ENV of test" do
      let(:args) { { env: "test" } }

      %w[services api oidc].each do |subdomain|
        context "and given a subdomain of #{subdomain}" do
          let(:args) { super().merge(subdomain: subdomain) }

          context "with a path of foo" do
            let(:args) { super().merge(path: "foo") }

            it { expect(service.call).to eql URI("https://test-#{subdomain}.signin.education.gov.uk/foo") }
          end

          context "with no path" do
            it { expect(service.call).to eql URI("https://test-#{subdomain}.signin.education.gov.uk/") }
          end
        end
      end

      context "and given no subdomin" do
        context "with a path of foo" do
          let(:args) { super().merge(path: "foo") }

          it { expect(service.call).to eql URI("https://test-services.signin.education.gov.uk/foo") }
        end

        context "with no path" do
          it { expect(service.call).to eql URI("https://test-services.signin.education.gov.uk/") }
        end
      end
    end

    context "when no DSI_ENV has been set" do
      let(:args) { {} }

      %w[services api oidc].each do |subdomain|
        context "and given a subdomain of #{subdomain}" do
          let(:args) { super().merge(subdomain: subdomain) }

          context "with a path of foo" do
            let(:args) { super().merge(path: "foo") }

            it { expect(service.call).to eql URI("https://#{subdomain}.signin.education.gov.uk/foo") }
          end

          context "with no path" do
            it { expect(service.call).to eql URI("https://#{subdomain}.signin.education.gov.uk/") }
          end
        end
      end

      context "and given no subdomin" do
        context "with a path of foo" do
          let(:args) { super().merge(path: "foo") }

          it { expect(service.call).to eql URI("https://services.signin.education.gov.uk/foo") }
        end

        context "with no path" do
          it { expect(service.call).to eql URI("https://services.signin.education.gov.uk/") }
        end
      end
    end
  end
end
