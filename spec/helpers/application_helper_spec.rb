require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  around do |example|
    ClimateControl.modify(APPLICATION_URL: "https://get-help-buying-for-schools.education.gov.uk") { example.run }
  end

  describe "#fabs_govuk_link_to" do
    let(:external_url) { "https://example.com/foo" }
    let(:internal_url) { "/privacy-policy" }

    context "with external URLs" do
      it "adds rel noopener noreferrer attribute" do
        result = helper.fabs_govuk_link_to("External", external_url)
        expect(result).to include('rel="noopener noreferrer"')
      end

      it "adds target blank attribute" do
        result = helper.fabs_govuk_link_to("External", external_url)
        expect(result).to include('target="_blank"')
      end

      it "adds visually hidden text for screen readers" do
        result = helper.fabs_govuk_link_to("External", external_url)
        expect(result).to include('<span class="govuk-visually-hidden"> opens in new tab</span>')
      end
    end

    context "with internal URLs" do
      it "uses a fully qualified application URL as the href" do
        result = helper.fabs_govuk_link_to("Internal", internal_url)
        expect(result).to include('href="https://get-help-buying-for-schools.education.gov.uk/privacy-policy"')
      end

      it "does not add rel noopener noreferrer attribute" do
        result = helper.fabs_govuk_link_to("Internal", internal_url)
        expect(result).not_to include('rel="noopener noreferrer"')
      end

      it "does not add target blank attribute" do
        result = helper.fabs_govuk_link_to("Internal", internal_url)
        expect(result).not_to include('target="_blank"')
      end

      it "does not add visually hidden text" do
        result = helper.fabs_govuk_link_to("Internal", internal_url)
        expect(result).not_to include('<span class="govuk-visually-hidden"> (opens in new tab)</span>')
      end
    end

    context "with get-help-buying-for-schools URLs" do
      it "converts staging and service URLs to fully qualified application URLs" do
        result = helper.fabs_govuk_link_to("Energy", "https://staging.get-help-buying-for-schools.education.gov.uk/energy/before-you-start")
        expect(result).to include('href="https://get-help-buying-for-schools.education.gov.uk/energy/before-you-start"')
      end

      it "preserves query strings and fragments when converting to application URLs" do
        result = helper.fabs_govuk_link_to("Energy", "https://staging.get-help-buying-for-schools.education.gov.uk/energy/before-you-start?source=email#start")
        expect(result).to include('href="https://get-help-buying-for-schools.education.gov.uk/energy/before-you-start?source=email#start"')
      end

      it "does not treat converted URLs as external" do
        result = helper.fabs_govuk_link_to("Energy", "https://staging.get-help-buying-for-schools.education.gov.uk/energy/before-you-start")

        expect(result).not_to include('rel="noopener noreferrer"')
        expect(result).not_to include('target="_blank"')
        expect(result).not_to include('<span class="govuk-visually-hidden"> opens in new tab</span>')
      end
    end

    context "with non-get-help-buying-for-schools URLs" do
      it "keeps the external URL as the href" do
        result = helper.fabs_govuk_link_to("External", "https://example.com/cookie-policy")
        expect(result).to include('href="https://example.com/cookie-policy"')
      end
    end

    it "preserves additional options" do
      result = helper.fabs_govuk_link_to("Link", "/path", class: "custom-class")
      expect(result).to include('class="govuk-link custom-class"')
    end
  end

  describe "#customer_satisfaction_survey_url" do
    it "builds a fully qualified survey URL from APPLICATION_URL" do
      expect(helper.customer_satisfaction_survey_url("footer_link")).to eq(
        "https://get-help-buying-for-schools.education.gov.uk/customer_satisfaction_surveys/new?service=find_a_buying_solution&source=footer_link",
      )
    end
  end

  describe "#usability_survey_url" do
    before do
      allow(UrlVerifier).to receive(:generate).and_return("signed-return-url")
      allow(helper.request).to receive(:original_url).and_return("https://get-help-buying-for-schools.education.gov.uk/current-page")
    end

    it "uses a fully qualified application URL for a relative path" do
      result = helper.usability_survey_url("/custom-page")

      expect(result).to eq(
        "https://get-help-buying-for-schools.education.gov.uk/usability_surveys/new?return_url=signed-return-url&service=find_a_buying_solution",
      )
      expect(UrlVerifier).to have_received(:generate).with("https://get-help-buying-for-schools.education.gov.uk/custom-page")
    end

    it "falls back to the current request URL for invalid input" do
      helper.usability_survey_url(nil)

      expect(UrlVerifier).to have_received(:generate).with("https://get-help-buying-for-schools.education.gov.uk/current-page")
    end
  end

  describe "#page_title" do
    context "when page_title is nil" do
      it "returns just the service name" do
        expect(helper.page_title(nil)).to eq(I18n.t("service.name"))
      end
    end

    context "when page_title is blank" do
      it "returns just the service name" do
        expect(helper.page_title("")).to eq(I18n.t("service.name"))
      end
    end

    context "when page_title is present" do
      it "returns page title with service name" do
        expect(helper.page_title("Custom Page")).to eq("Custom Page - #{I18n.t('service.name')}")
      end
    end
  end
end
