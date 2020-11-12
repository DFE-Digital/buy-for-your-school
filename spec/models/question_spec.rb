require "rails_helper"

RSpec.describe Question, type: :model do
  it { should belong_to(:plan) }
  it { should have_one(:radio_answer) }
  it { should have_one(:short_text_answer) }

  it "store the basic fields of a contentful response" do
    question = build(:question,
      :radio,
      title: "foo",
      help_text: "bar",
      options: ["baz", "boo"])

    expect(question.title).to eql("foo")
    expect(question.help_text).to eql("bar")
    expect(question.options).to eql(["baz", "boo"])
  end

  it "captures the raw contentful response" do
    contentful_json_response = JSON("foo": {})
    question = build(:question,
      raw: contentful_json_response)

    expect(question.raw).to eql("{\"foo\":{}}")
  end

  describe "#answer" do
    context "when a RadioAnswer is associated to the question" do
      it "returns the RadioAnswer object" do
        radio_answer = create(:radio_answer)
        question = create(:question, :radio, radio_answer: radio_answer)
        expect(question.answer).to eq(radio_answer)
      end
    end

    context "when a ShortTextAnswer is associated to the question" do
      it "returns the ShortTextAnswer object" do
        short_text_answer = create(:short_text_answer)
        question = create(:question, :short_text, short_text_answer: short_text_answer)
        expect(question.answer).to eq(short_text_answer)
      end
    end
  end
end
