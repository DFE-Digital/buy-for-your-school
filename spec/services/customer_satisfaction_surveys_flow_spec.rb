# spec/services/customer_satisfaction_surveys_flow_spec.rb
require 'rails_helper'

RSpec.describe CustomerSatisfactionSurveysFlow do
  let(:service_name) { :sample_service }
  let(:flow_steps) { ['start_step', 'question', 'improvement', 'thank_you'] }

  before do
    stub_const("SURVEY_FLOWS", { service_name => flow_steps })
  end

  describe '#initialize' do
    it 'sets the current step to the first step if none is provided' do
      flow = described_class.new(service_name)
      expect(flow.current_step).to eq('start_step')
    end

    it 'sets the current step if provided' do
      flow = described_class.new(service_name, 'questions')
      expect(flow.current_step).to eq('questions')
    end
  end

  describe '#all_steps' do
    it 'returns the full flow steps' do
      flow = described_class.new(service_name)
      expect(flow.all_steps).to eq(flow_steps)
    end
  end

  describe '#next_step and #next_path' do
    it 'returns the next step and path' do
      flow = described_class.new(service_name, 'start_step')
      expect(flow.next_step).to eq('questions')
      expect(flow.next_path).to eq('edit_customer_satisfaction_surveys_questions_path')
    end
  end

  describe '#previous_step and #back_path' do
    it 'returns the previous step and path' do
      flow = described_class.new(service_name, 'improvement')
      expect(flow.previous_step).to eq('questions')
      expect(flow.back_path).to eq('edit_customer_satisfaction_surveys_questions_path')
    end
  end

  describe '#current_path' do
    it 'returns the correct path for the current step' do
      flow = described_class.new(service_name, 'improvement')
      expect(flow.current_path).to eq('edit_customer_satisfaction_surveys_improvements_path')
    end

    it 'returns thank you path correctly' do
      flow = described_class.new(service_name, 'thank_you')
      expect(flow.current_path).to eq('customer_satisfaction_surveys_thank_you_path')
    end
  end
end
