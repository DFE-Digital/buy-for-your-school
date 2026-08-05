require "rails_helper"

RSpec.describe RedirectMatcher do
  describe ".cached_redirects" do
    before do
      allow(described_class).to receive(:cached_redirects).and_call_original
    end

    it "loads redirects through Rails cache" do
      redirects = [instance_double(Redirect)]

      allow(Rails.cache).to receive(:fetch).with(
        described_class::CACHE_KEY,
        expires_in: described_class::CACHE_EXPIRY,
      ).and_yield
      allow(Redirect).to receive(:all).and_return(redirects)

      expect(described_class.cached_redirects).to eq(redirects)
    end
  end

  describe ".call" do
    subject(:result) { described_class.call(path, redirects:) }

    let(:redirects) { [redirect] }

    context "when an exact permanent redirect matches" do
      let(:path) { "/about-this-service" }
      let(:redirect) do
        instance_double(
          Redirect,
          source_path: "/about-this-service",
          destination_path: "/about-our-service",
          permanent?: true,
        )
      end

      it "returns the matched redirect result" do
        expect(result.redirect).to eq(redirect)
        expect(result.destination_path).to eq("/about-our-service")
        expect(result.status).to eq(:moved_permanently)
      end
    end

    context "when a wildcard permanent redirect matches a category page" do
      let(:path) { "/categories/it" }
      let(:redirect) do
        instance_double(
          Redirect,
          source_path: "/categories/it/*",
          destination_path: "/categories/ict-business-systems/*",
          permanent?: true,
        )
      end

      it "maps to the destination prefix" do
        expect(result.destination_path).to eq("/categories/ict-business-systems")
        expect(result.status).to eq(:moved_permanently)
      end
    end

    context "when a wildcard temporary redirect matches a solution page" do
      let(:path) { "/categories/it/communications-solutions" }
      let(:redirect) do
        instance_double(
          Redirect,
          source_path: "/categories/it/*",
          destination_path: "/categories/ict-business-systems/*",
          permanent?: false,
        )
      end

      it "preserves the wildcard remainder in the destination path" do
        expect(result.destination_path).to eq("/categories/ict-business-systems/communications-solutions")
        expect(result.status).to eq(:found)
      end
    end

    context "when multiple redirects match" do
      let(:path) { "/categories/it/communications-solutions" }
      let(:first_redirect) do
        instance_double(
          Redirect,
          source_path: "/categories/it/*",
          destination_path: "/categories/ict-business-systems/*",
          permanent?: true,
        )
      end
      let(:second_redirect) do
        instance_double(
          Redirect,
          source_path: "/categories/it/*",
          destination_path: "/categories/other/*",
          permanent?: true,
        )
      end
      let(:redirects) { [first_redirect, second_redirect] }

      it "returns the first matching redirect" do
        expect(result.redirect).to eq(first_redirect)
        expect(result.destination_path).to eq("/categories/ict-business-systems/communications-solutions")
      end
    end

    context "when no redirect matches" do
      let(:path) { "/no-match" }
      let(:redirect) do
        instance_double(
          Redirect,
          source_path: "/about-this-service",
          destination_path: "/about-our-service",
          permanent?: true,
        )
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
