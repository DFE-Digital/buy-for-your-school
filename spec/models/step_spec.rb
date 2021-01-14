require "rails_helper"

RSpec.describe Step, type: :model do
  it { should belong_to(:journey) }
  it { should have_one(:radio_answer) }
  it { should have_one(:short_text_answer) }
  it { should have_one(:long_text_answer) }
  it { should have_one(:single_date_answer) }
  it { should have_one(:checkbox_answers) }

  it "store the basic fields of a contentful response" do
    step = build(:step,
      :radio,
      title: "foo",
      help_text: "bar",
      options: ["baz", "boo"])

    expect(step.title).to eql("foo")
    expect(step.help_text).to eql("bar")
    expect(step.options).to eql([{"value" => "baz"}, {"value" => "boo"}])
  end

  it "captures the raw contentful response" do
    step = build(:step, raw: {foo: "bar"})
    expect(step.raw).to eql({"foo" => "bar"})
  end

  describe "#that_are_questions" do
    it "only returns steps that have the question contentful_model" do
      question_step = create(:step, :radio)
      static_content_step = create(:step, :static_content)

      expect(described_class.that_are_questions).to include(question_step)
      expect(described_class.that_are_questions).not_to include(static_content_step)
    end
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

    context "when a SingleDateAnswer is associated to the step" do
      it "returns the SingleDateAnswer object" do
        single_date_answer = create(:single_date_answer)
        step = create(:step, :single_date, single_date_answer: single_date_answer)
        expect(step.answer).to eq(single_date_answer)
      end
    end

    context "when a CheckboxAnswers is associated to the step" do
      it "returns the CheckboxAnswers object" do
        checkbox_answers = create(:checkbox_answers)
        step = create(:step, :checkbox_answers, checkbox_answers: checkbox_answers)
        expect(step.answer).to eq(checkbox_answers)
      end
    end
  end

  describe "#options" do
    # TODO: This will need updating when options are set on the step with the new format
    it "returns a hash of options" do
      step = build(:step,
        :radio,
        options: "",
        raw: {
          fields: {
            "extendedOptions" => [
              {"value" => "foo", "other_config" => false}
            ]
          }
        })

      expect(step.options).to eql([{"value" => "foo", "other_config" => false}])
    end

    # TODO: Remove this when we no longer need to support options coming from
    # contentful in this old format
    context "when options exist in the old flat list format" do
      it "returns these values converted into a simple hash of values" do
        step = build(:step,
          :radio,
          options: ["Yes", "No"])

        expect(step.options).to eql([{"value" => "Yes"}, {"value" => "No"}])
      end
    end
  end
end
