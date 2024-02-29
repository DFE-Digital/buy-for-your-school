require "rails_helper"

describe CustomerSatisfactionSurveyResponse::Presentable do
  describe "satisfaction_text_* methods" do
    subject(:presentable) { CustomerSatisfactionSurveyResponse.new(satisfaction_level:, satisfaction_text:) }

    let(:satisfaction_level) { nil }
    let(:satisfaction_text) { "reasons" }

    context "when satisfaction_level is 'very_satisfied'" do
      let(:satisfaction_level) { :very_satisfied }

      describe "satisfaction_text_very_satisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_very_satisfied).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'satisfied'" do
      let(:satisfaction_level) { :satisfied }

      describe "satisfaction_text_satisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_satisfied).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'neither'" do
      let(:satisfaction_level) { :neither }

      describe "satisfaction_text_neither" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_neither).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'dissatisfied'" do
      let(:satisfaction_level) { :dissatisfied }

      describe "satisfaction_text_dissatisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_dissatisfied).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'very_dissatisfied'" do
      let(:satisfaction_level) { :very_dissatisfied }

      describe "satisfaction_text_very_dissatisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_very_dissatisfied).to eq(satisfaction_text)
        end
      end
    end
  end
end
