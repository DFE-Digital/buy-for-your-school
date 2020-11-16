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
end
