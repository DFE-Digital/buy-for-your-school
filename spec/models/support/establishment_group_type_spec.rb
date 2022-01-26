require "rails_helper"

RSpec.describe Support::EstablishmentGroupType, type: :model do
  it { is_expected.to have_many(:groups) }
end
