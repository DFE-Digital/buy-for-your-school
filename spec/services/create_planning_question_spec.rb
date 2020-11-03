require "rails_helper"

RSpec.describe CreatePlanningQuestion do
  describe "#call" do
    it "creates a local copy of the new question" do
      plan = create(:plan, :catering)
      raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")
      fake_contentful_question_response = JSON.parse(raw_response)
      stub_contentful_question(response: fake_contentful_question_response)

      result = described_class.new(plan: plan).call

      expect(result.title).to eq("Which service do you need?")
      expect(result.help_text).to eq("Tell us which service you need.")
      expect(result.contentful_type).to eq("radios")
      expect(result.options).to eq(["Catering", "Cleaning"])
      expect(result.raw).to eq(fake_contentful_question_response.to_s)
    end
  end

  def stub_contentful_question(response: {"fields" => {"title" => "Which service do you need?"}})
    get_contentful_question_double = instance_double(GetContentfulEntry)
    allow(GetContentfulEntry).to receive(:new).and_return(get_contentful_question_double)
    allow(get_contentful_question_double).to receive(:call).and_return(response)
  end
end
