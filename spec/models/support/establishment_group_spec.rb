require 'rails_helper'

RSpec.describe Support::EstablishmentGroup, type: :model do
  it { is_expected.to belong_to(:establishment_group_type) }
end
