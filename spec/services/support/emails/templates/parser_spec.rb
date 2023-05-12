require "rails_helper"

describe Support::Emails::Templates::Parser do
  subject(:service) { described_class.new(agent:) }

  let(:agent) { nil }

  describe "#parse" do
    let(:agent) { Support::AgentPresenter.new(build(:support_agent, first_name: "Avery", last_name: "Jones")) }
    let(:body) { "hello {{caseworker_full_name}}" }
    let(:parsed) { double("parsed") }
    let(:template_context) { { "caseworker_full_name" => "Avery Jones" } }

    before do
      allow(parsed).to receive(:render)
      allow(Liquid::Template).to receive(:parse).and_return(parsed)
      service.parse(body)
    end

    it "calls on liquid to parse the template" do
      expect(Liquid::Template).to have_received(:parse).with(body, error_mode: :strict)
      expect(parsed).to have_received(:render).with(template_context)
    end
  end
end
