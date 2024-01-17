require "rails_helper"

describe CustomerSatisfactionSurveyResponse::Presentable do
  describe "satisfaction_text_* methods" do
    subject(:presentable) { CustomerSatisfactionSurveyResponse.new(satisfaction_level:, satisfaction_text:) }

    let(:satisfaction_level) { nil }
    let(:satisfaction_text) { "reasons" }

    context "when satisfaction_level is 'extremely_satisfied'" do
      let(:satisfaction_level) { :extremely_satisfied }

      describe "satisfaction_text_extremely_satisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_extremely_satisfied).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'very_satisfied'" do
      let(:satisfaction_level) { :very_satisfied }

      describe "satisfaction_text_very_satisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_very_satisfied).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'neutral'" do
      let(:satisfaction_level) { :neutral }

      describe "satisfaction_text_neutral" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_neutral).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'slightly_satisfied'" do
      let(:satisfaction_level) { :slightly_satisfied }

      describe "satisfaction_text_slightly_satisfied" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_slightly_satisfied).to eq(satisfaction_text)
        end
      end
    end

    context "when satisfaction_level is 'not_satisfied_at_all'" do
      let(:satisfaction_level) { :not_satisfied_at_all }

      describe "satisfaction_text_not_satisfied_at_all" do
        it "returns satisfaction_text" do
          expect(presentable.satisfaction_text_not_satisfied_at_all).to eq(satisfaction_text)
        end
      end
    end
  end
end
