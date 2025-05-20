require "rails_helper"

describe Support::SeedProcurementStages do
  subject(:service) { described_class.new }

  let(:stages) { Support::ProcurementStage.all }

  it "populates the table" do
    expect { service.call }
      .to change(stages, :count).from(0).to(26)
  end

  it "sets expected values" do
    service.call
    stage = Support::ProcurementStage.first
    expect(stage.title).to eq("Need")
    expect(stage.key).to eq("need")
    expect(stage.stage).to eq(0)
    expect(stage.archived).to be(false)
    expect(stage.lifecycle_order).to eq(0)
  end
end
