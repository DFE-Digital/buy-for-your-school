RSpec.describe Support::CaseProcurementDetailsForm, type: :model do
  subject(:form) { described_class.new }

  it "#messages" do
    expect(form.messages).to be_a Hash
    expect(form.messages).to be_empty
    expect(form.errors.messages).to be_a Hash
    expect(form.errors.messages).to be_empty
  end

  it "#errors" do
    expect(form.errors).to be_a Support::Form::ErrorSummary
    expect(form.errors.any?).to be false
  end

  it "form params" do
    expect(form.required_agreement_type).to be_nil
    expect(form.route_to_market).to be_nil
    expect(form.reason_for_route_to_market).to be_nil
    expect(form.framework_name).to be_nil
    expect(form.started_at).to be_nil
    expect(form.ended_at).to be_nil
  end
end
