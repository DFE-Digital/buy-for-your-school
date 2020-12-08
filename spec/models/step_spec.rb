require "rails_helper"

RSpec.describe Step, type: :model do
  it { should belong_to(:journey) }
  it { should have_one(:radio_answer) }
  it { should have_one(:short_text_answer) }
  it { should have_one(:long_text_answer) }

  it "store the basic fields of a contentful response" do
    step = build(:step,
      :radio,
      title: "foo",
      help_text: "bar",
      options: ["baz", "boo"])

    expect(step.title).to eql("foo")
    expect(step.help_text).to eql("bar")
    expect(step.options).to eql(["baz", "boo"])
  end

  it "captures the raw contentful response" do
    contentful_json_response = JSON("foo": {})
    step = build(:step,
      raw: contentful_json_response)

    expect(step.raw).to eql("{\"foo\":{}}")
  end

  describe "#answer" do
    context "when a RadioAnswer is associated to the step" do
      it "returns the RadioAnswer object" do
        radio_answer = create(:radio_answer)
        step = create(:step, :radio, radio_answer: radio_answer)
        expect(step.answer).to eq(radio_answer)
      end
    end

    context "when a ShortTextAnswer is associated to the step" do
      it "returns the ShortTextAnswer object" do
        short_text_answer = create(:short_text_answer)
        step = create(:step, :short_text, short_text_answer: short_text_answer)
        expect(step.answer).to eq(short_text_answer)
      end
    end

    context "when a LongTextAnswer is associated to the step" do
      it "returns the LongTextAnswer object" do
        long_text_answer = create(:long_text_answer)
        step = create(:step, :long_text, long_text_answer: long_text_answer)
        expect(step.answer).to eq(long_text_answer)
      end
    end
  end

  describe "#question?" do
    context "when the contentful model is 'question'" do
      it "returns true" do
        step = build(:step, :radio, contentful_model: "question")
        expect(step.question?).to eq(true)
      end
    end

    context "when the contentful model is NOT 'question'" do
      it "returns false" do
        step = build(:step, contentful_model: "staticContent")
        expect(step.question?).to eq(false)
      end
    end
  end
end
