require "rails_helper"

describe Support::ProcurementStage, type: :model do
  it { is_expected.to have_many(:cases).class_name("Support::Case") }
end
