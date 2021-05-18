require "rails_helper"

RSpec.describe CheckboxesAnswerPresenter do
  describe "#response" do
    it "returns all none nil values as an array" do
      step = build(:checkbox_answers, response: ["Yes", "No", "Morning break", ""])
      presenter = described_class.new(step)
      expect(presenter.response).to eq(["Yes", "No", "Morning break"])
    end
  end

  describe "#to_param" do
    it "returns a hash of options" do
      step = build(:checkbox_answers,
        response: ["Yes", "No"],
        skipped: false,
        further_information: {
          yes_further_information: "More yes info",
          no_further_information: "More no info"
        })

      presenter = described_class.new(step)

      expect(presenter.to_param).to eql({
        response: ["Yes", "No"],
        skipped: false,
        concatenated_response: "Yes, No",
        selected_answers: [
          {
            machine_value: :yes,
            human_value: "Yes",
            further_information: "More yes info"
          },
          {
            machine_value: :no,
            human_value: "No",
            further_information: "More no info"
          }
        ]
      })
    end

    context "when there is no response" do
      it "sets the response to an empty array" do
        step = build(:checkbox_answers, response: [])
        presenter = described_class.new(step)
        expect(presenter.to_param).to include({response: []})
      end

      it "sets the concatenated_response to an array with an empty hash" do
        step = build(:checkbox_answers, response: [])
        presenter = described_class.new(step)
        expect(presenter.to_param).to include({selected_answers: []})
      end

      it "sets the concatenated_response to a nil" do
        step = build(:checkbox_answers, response: [])
        presenter = described_class.new(step)
        expect(presenter.to_param).to include({concatenated_response: nil})
      end
    end

    context "when the answer is skipped" do
      it "sets the skipped value to true" do
        step = build(:checkbox_answers, skipped: true)
        presenter = described_class.new(step)
        expect(presenter.to_param).to include({skipped: true})
      end
    end

    context "when the option includes special characters" do
      it "the further_information is correctly returned" do
        step = build(:checkbox_answers,
          response: ["Other, please specify"],
          further_information: {other_please_specify_further_information: "Sinks and stuff"})
        presenter = described_class.new(step)
        expect(presenter.to_param).to eql({
          response: ["Other, please specify"],
          skipped: false,
          concatenated_response: "Other, please specify",
          selected_answers: [
            {
              machine_value: :other_please_specify,
              human_value: "Other, please specify",
              further_information: "Sinks and stuff"
            }
          ]
        })
      end
    end
  end
end
