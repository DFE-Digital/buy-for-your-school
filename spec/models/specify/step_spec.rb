RSpec.describe Step, type: :model do
  it { is_expected.to belong_to(:task) }
  it { is_expected.to have_one(:radio_answer) }
  it { is_expected.to have_one(:short_text_answer) }
  it { is_expected.to have_one(:long_text_answer) }
  it { is_expected.to have_one(:single_date_answer) }
  it { is_expected.to have_one(:checkbox_answers) }

  it "store the basic fields of a contentful response" do
    step = build(:step,
                 :radio,
                 title: "foo",
                 help_text: "bar",
                 options: [{ "value" => "baz" }, { "value" => "boo" }])

    expect(step.title).to eql("foo")
    expect(step.help_text).to eql("bar")
    expect(step.options).to eql([{ "value" => "baz" }, { "value" => "boo" }])
  end

  it "captures the raw contentful response" do
    step = build(:step, raw: { foo: "bar" })
    expect(step.raw).to eql({ "foo" => "bar" })
  end

  describe "#that_are_questions" do
    it "only returns steps that have the question contentful_model" do
      question = create(:step, :radio)
      statement = create(:step, :statement)

      expect(described_class.that_are_questions).to include(question)
      expect(described_class.that_are_questions).not_to include(statement)
    end
  end

  describe "#that_are_statements" do
    it "only returns steps that have the statement contentful_model" do
      statement = create(:step, :statement)
      question = create(:step, :radio)

      expect(described_class.that_are_statements).to include(statement)
      expect(described_class.that_are_statements).not_to include(question)
    end
  end

  describe "#answer" do
    context "when a question of type 'number' is answered" do
      it "returns the NumberAnswer object" do
        answer = create(:number_answer)
        question = create(:step, :number, number_answer: answer)
        expect(question.answer).to be_a NumberAnswer
      end
    end

    context "when a question of type 'currency' is answered" do
      it "returns the CurrencyAnswer object" do
        answer = create(:currency_answer)
        question = create(:step, :currency, currency_answer: answer)
        expect(question.answer).to be_a CurrencyAnswer
      end
    end

    context "when a question of type 'radios' is answered" do
      it "returns the RadioAnswer object" do
        answer = create(:radio_answer)
        question = create(:step, :radio, radio_answer: answer)
        expect(question.answer).to be_a RadioAnswer
      end
    end

    context "when a question of type 'short_text' is answered" do
      it "returns the ShortTextAnswer object" do
        answer = create(:short_text_answer)
        question = create(:step, :short_text, short_text_answer: answer)
        expect(question.answer).to be_a ShortTextAnswer
      end
    end

    context "when a question of type 'long_text' is answered" do
      it "returns the LongTextAnswer object" do
        answer = create(:long_text_answer)
        question = create(:step, :long_text, long_text_answer: answer)
        expect(question.answer).to be_a LongTextAnswer
      end
    end

    context "when a question of type 'single_date' is answered" do
      it "returns the SingleDateAnswer object" do
        answer = create(:single_date_answer)
        question = create(:step, :single_date, single_date_answer: answer)
        expect(question.answer).to be_a SingleDateAnswer
      end
    end

    context "when a question of type 'checkboxes' is answered" do
      it "returns the CheckboxAnswers object" do
        answer = create(:checkbox_answers)
        question = create(:step, :checkbox, checkbox_answers: answer)
        expect(question.answer).to be_a CheckboxAnswers
      end
    end
  end

  describe "#skippable?" do
    it "returns true if there is skip_call_to_action_text" do
      step = build(:step, skip_call_to_action_text: "None of the above")
      result = step.skippable?
      expect(result).to be true
    end

    it "returns false if there is NOT skip_call_to_action_text" do
      step = build(:step, skip_call_to_action_text: nil)
      result = step.skippable?
      expect(result).to be false
    end
  end

  describe "#acknowledge!" do
    let(:statement) { create(:step, :statement) }

    it "adds the id to the parent task's acknowledged statement list" do
      expect(statement.acknowledge!).to be true
      expect(statement.task.statement_ids).to include statement.id
    end
  end

  describe "#acknowledged?" do
    let(:statement) { create(:step, :statement) }

    it "returns true if the statement has been acknowledged" do
      statement.acknowledge!
      expect(statement.acknowledged?).to be true
    end

    it "returns false if the statement has NOT been acknowledged" do
      expect(statement.acknowledged?).to be false
    end
  end

  describe "#answered?" do
    it "returns true if there is an answer" do
      answer = create(:single_date_answer)
      question = create(:step, :single_date, single_date_answer: answer)
      expect(question.answered?).to be true
    end

    it "returns false if there is NOT an answer" do
      question = create(:step, :single_date)
      expect(question.answered?).to be false
    end
  end

  describe "#completed?" do
    context "when the step is a question" do
      it "returns true if there is an answer" do
        answer = create(:single_date_answer)
        question = create(:step, :single_date, single_date_answer: answer)
        expect(question.completed?).to be true
      end

      it "returns false if there is NOT an answer" do
        question = create(:step, :single_date)
        expect(question.completed?).to be false
      end
    end

    context "when the step is a statement" do
      let(:statement) { create(:step, :statement) }

      it "returns true if the statement has been acknowledged" do
        statement.acknowledge!
        expect(statement.completed?).to be true
      end

      it "returns false if the statement has NOT been acknowledged" do
        expect(statement.completed?).to be false
      end
    end
  end

  describe "#options" do
    # TODO: WHAT IS THE NEW FORMAT?? This will need updating when options are set on the step with the new format
    it "returns a hash of options" do
      step = build(:step,
                   :radio,
                   options: [{ "value" => "foo", "other_config" => false }])

      expect(step.options).to eql([{ "value" => "foo", "other_config" => false }])
    end
  end

  describe "#criteria" do
    it "returns a hash of validation criteria" do
      step = build(:step,
                   :single_date,
                   criteria: {
                     "message": "Are you a time traveller!",
                     "lower": "1947-10-13 12:34",
                     "upper": "2000-01-01 00:01)",
                   })

      expect(step.criteria).to eql({
        "message" => "Are you a time traveller!",
        "upper" => "2000-01-01 00:01)",
        "lower" => "1947-10-13 12:34",
      })
    end
  end

  describe "#skip!" do
    let(:task) { create(:task) }
    let(:step) { create(:step, :number, task:) }

    it "records skipped step if not present" do
      expect(task.skipped_ids.size).to eq 0
      step.skip!
      expect(task.skipped_ids.size).to eq 1
      expect(task.skipped_ids.first).to eq step.id
    end

    it "has no effect if step is already present" do
      step.skip!
      expect(task.skipped_ids.size).to eq 1
      step.skip!
      expect(task.skipped_ids.size).to eq 1
    end
  end

  describe "#unskip!" do
    let(:task) { create(:task) }
    let(:step) { create(:step, :number, task:) }

    it "removes existing ID if present" do
      step.skip!
      expect(task.skipped_ids.size).to eq 1
      step.unskip!
      expect(task.skipped_ids.size).to eq 0
    end

    it "has no effect if step is not present" do
      expect(task.skipped_ids.size).to eq 0
      step.unskip!
      expect(task.skipped_ids.size).to eq 0
    end
  end

  describe "#skipped?" do
    let(:task) { create(:task) }
    let(:step) { create(:step, :number, task:) }

    it "returns true if step is skipped" do
      step.skip!
      expect(step.skipped?).to be true
    end

    it "returns false if step is not skipped" do
      expect(step.skipped?).to be false
    end

    it "returns false if step is unskipped" do
      step.skip!
      expect(step.skipped?).to be true
      step.unskip!
      expect(step.skipped?).to be false
    end
  end

  describe "#last?" do
    let(:task) { create(:task) }
    let!(:step_1) { create(:step, :number, task:, order: 1) }
    let!(:step_2) { create(:step, :number, task:, order: 2) }

    it "returns true if a given step is the last one" do
      expect(step_2.last?).to be true
    end

    it "returns false if a given step is not the last one" do
      expect(step_1.last?).to be false
    end
  end

  describe "#last_skipped?" do
    let(:task) { create(:task) }
    let(:step_1) { create(:step, :number, task:) }
    let(:step_2) { create(:step, :number, task:) }

    before do
      step_1.skip!
      step_2.skip!
    end

    it "returns true if a given step is the last skipped one" do
      expect(step_2.last_skipped?).to be true
    end

    it "returns false if a given step is not the last skipped one" do
      expect(step_1.last_skipped?).to be false
    end
  end
end
