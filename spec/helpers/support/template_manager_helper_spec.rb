require "rails_helper"

RSpec.describe Support::TemplateManagerHelper do
  describe "email_template_manager_editor" do
    let(:filter_url) { "https://www.example.com" }

    before do
      allow(helper).to receive(:render)
    end

    it "passes parameters to the view" do
      helper.email_template_manager_editor(filter_url:)
      expect(helper).to have_received(:render).with("support/management/email_templates/template_manager/template_manager", { mode: :edit, filter_url:, use_url: nil, hidden_fields_hash: {} })
    end
  end

  describe "email_template_manager_selector" do
    let(:filter_url) { "https://www.example.com" }
    let(:use_url) { "https://www.example.com" }
    let(:hidden_fields_hash) { { field: "value" } }

    before do
      allow(helper).to receive(:render)
    end

    it "passes parameters to the view" do
      helper.email_template_manager_selector(filter_url:, use_url:, hidden_fields_hash:)
      expect(helper).to have_received(:render).with("support/management/email_templates/template_manager/template_manager", { mode: :select, filter_url:, use_url:, hidden_fields_hash: })
    end
  end
end
